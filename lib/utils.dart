import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/models.dart';
import 'strings.dart';

const List<String> orderStatuses = ['Pending', 'Delivering', 'Completed'];

// ---------- Formatting ----------

String money(double v) {
  final parts = v.toStringAsFixed(2).split('.');
  final whole = parts[0]
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  return '\$$whole.${parts[1]}';
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDay(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  final day = d.day.toString().padLeft(2, '0');
  return '$day ${_months[d.month - 1]} ${d.year}';
}

String formatDateTime(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  final ap = d.hour >= 12 ? 'PM' : 'AM';
  return '${formatDay(iso)}, $h:$m $ap';
}

String cleanError(Object e) =>
    e.toString().replaceFirst('Exception: ', '');

// ---------- Validation ----------

class Validators {
  Validators._();

  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? S.errRequired : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return S.errRequired;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : S.errEmail;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return S.errRequired;
    final digits = v.replaceAll(RegExp(r'[\s\-+]'), '');
    return RegExp(r'^\d{8,15}$').hasMatch(digits) ? null : S.errPhone;
  }

  static String? newPassword(String? v) {
    if (v == null || v.isEmpty) return S.errRequired;
    return v.length < 6 ? S.errPassword : null;
  }

  static String? price(String? v) {
    final n = double.tryParse((v ?? '').trim());
    return (n == null || n < 0) ? S.errPrice : null;
  }

  static String? stock(String? v) {
    final n = int.tryParse((v ?? '').trim());
    return (n == null || n < 0) ? S.errStock : null;
  }
}

// ---------- Session ----------

class SessionManager {
  static const _key = 'user_id';

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key);
  }

  Future<void> save(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, id);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

// ---------- CSV reader ----------

class CsvLoader {
  /// Line format: category,name,price,stock,icon,description
  /// The description is everything after the fifth comma.
  static Future<List<SeedProduct>> loadProducts(String assetPath) async {
    final text = (await rootBundle.loadString(assetPath)).replaceAll('\uFEFF', '');
    final rows = <SeedProduct>[];
    for (final raw in text.split(RegExp(r'\r?\n'))) {
      final line = raw.trim();
      if (line.isEmpty ||
          line.startsWith('#') ||
          line.toLowerCase().startsWith('category,')) {
        continue;
      }
      final parts = line.split(',');
      if (parts.length < 6) continue;
      final price = double.tryParse(parts[2].trim());
      final stock = int.tryParse(parts[3].trim());
      if (price == null || stock == null) continue;
      rows.add(SeedProduct(
        category: parts[0].trim(),
        name: parts[1].trim(),
        price: price,
        stock: stock,
        icon: parts[4].trim(),
        description: parts.sublist(5).join(',').trim(),
      ));
    }
    return rows;
  }
}

// ---------- Text file export ----------

class Exporter {
  static String receiptText(Order o, List<OrderItem> items) {
    final subtotal = items.fold(0.0, (s, i) => s + i.lineTotal);
    final b = StringBuffer()
      ..writeln('POCKETMART RECEIPT')
      ..writeln('==========================')
      ..writeln('Order:    ${o.number}')
      ..writeln('Date:     ${formatDateTime(o.date)}')
      ..writeln('Customer: ${o.userName}')
      ..writeln('Status:   ${o.status}')
      ..writeln('--------------------------');
    for (final i in items) {
      b.writeln('${i.name}  ${i.quantity} x ${money(i.price)} = ${money(i.lineTotal)}');
    }
    b
      ..writeln('--------------------------')
      ..writeln('Subtotal:     ${money(subtotal)}')
      ..writeln('Delivery fee: ${money(o.total - subtotal)}')
      ..writeln('Total:        ${money(o.total)}')
      ..writeln('--------------------------')
      ..writeln('Address: ${o.address}')
      ..writeln('Phone:   ${o.phone}')
      ..writeln('Payment: ${S.cashOnDelivery}');
    return b.toString();
  }

  static String salesReportText(List<Order> orders, AdminStats stats) {
    final b = StringBuffer()
      ..writeln('POCKETMART SALES REPORT')
      ..writeln('Generated: ${formatDateTime(DateTime.now().toString().substring(0, 16))}')
      ..writeln('==========================')
      ..writeln('Total products: ${stats.products}')
      ..writeln('Total orders:   ${stats.orders}')
      ..writeln('Total revenue:  ${money(stats.revenue)}')
      ..writeln('Low stock:      ${stats.lowStock}')
      ..writeln('==========================');
    for (final o in orders) {
      b.writeln(
          '${o.number} | ${formatDay(o.date)} | ${o.userName} | ${o.itemCount} items | ${money(o.total)} | ${o.status}');
    }
    return b.toString();
  }

  /// Saves the text file in the app documents folder, then opens the share
  /// sheet so the user can send or save it. Returns the saved path.
  static Future<String> saveAndShare(String fileName, String text) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(text);
    await SharePlus.instance
        .share(ShareParams(files: [XFile(file.path)], subject: fileName));
    return file.path;
  }
}
