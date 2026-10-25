import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pocketmart_flutter/database/db_helper.dart';
import 'package:pocketmart_flutter/main.dart';
import 'package:pocketmart_flutter/providers/app_state.dart';
import 'package:pocketmart_flutter/strings.dart';
import 'package:pocketmart_flutter/utils.dart';
import 'package:pocketmart_flutter/widgets/common.dart';

/// Runs the app logic against a real SQLite database on the computer.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await databaseFactory
        .deleteDatabase(p.join(await getDatabasesPath(), 'pocketmart.db'));
    SharedPreferences.setMockInitialValues({});
  });

  group('Catalog', () {
    test('products.csv loads all 10 products', () async {
      final rows = await CsvLoader.loadProducts('assets/products.csv');
      expect(rows.length, 10);
      expect(rows.first.name, 'Linen Tote Bag');
    });

    test('every product has a photo in assets/images/products', () async {
      final rows = await CsvLoader.loadProducts('assets/products.csv');
      final missing = rows
          .where((r) => !File(productImagePath(r.name)).existsSync())
          .map((r) => r.name)
          .toList();
      expect(missing, isEmpty, reason: 'Missing photos: $missing');
    });
  });

  group('Customer and admin flows', () {
    final app = AppState();

    test('startup seeds categories and products', () async {
      await app.init();
      expect(app.initError, isNull);
      expect(app.ready, isTrue);
      expect(app.products.length, 10);
      expect(app.categories.map((c) => c.name),
          containsAll(['Clothing', 'Beauty', 'Home']));
    });

    test('startup adds 7 demo orders once', () async {
      final db = DbHelper.instance;
      final orders = await db.getOrders();
      expect(orders.length, 7);
      expect(orders.map((o) => o.status).toSet(),
          {'Pending', 'Delivering', 'Completed'});
      expect(orders.every((o) => o.itemCount > 0), isTrue);

      await db.seedDemoOrders(); // second run adds nothing
      expect((await db.getOrders()).length, 7);

      await app.login('ya@gmail.com', 'ya123456', false);
      expect(app.orders.length, 3);
      await app.logout();
    });

    test('register, log out, log in again', () async {
      await app.register('Sok Dara', 'dara@test.com', '012345678', 'secret1');
      expect(app.user!.firstName, 'Sok');
      expect(app.user!.isAdmin, isFalse);

      await app.logout();
      expect(app.user, isNull);

      await expectLater(app.login('dara@test.com', 'wrong', false),
          throwsA(isA<Exception>()));
      await expectLater(
          app.register('X', 'DARA@test.com', '012345678', 'secret1'),
          throwsA(isA<Exception>()));

      await app.login('dara@test.com', 'secret1', true);
      expect(app.user!.email, 'dara@test.com');
    });

    test('update profile', () async {
      await app.updateProfile('Sok Dara', '098765432', 'Phnom Penh');
      expect(app.user!.address, 'Phnom Penh');
      expect(app.user!.phone, '098765432');
    });

    test('wishlist toggles on and off', () async {
      final id = app.products.first.id;
      await app.toggleWishlist(id);
      expect(app.wishlist, contains(id));
      await app.toggleWishlist(id);
      expect(app.wishlist, isNot(contains(id)));
    });

    test('cart add, change quantity, stock limit, remove', () async {
      final mug = app.products.firstWhere((x) => x.name == 'Ceramic Mug');
      final candle = app.products.firstWhere((x) => x.name == 'Scented Candle');

      await app.addToCart(mug.id, 2);
      await app.addToCart(mug.id, 1); // same product merges into one line
      expect(app.cart.length, 1);
      expect(app.cart.first.quantity, 3);

      await app.changeQty(app.cart.first, 4);
      expect(app.cart.first.quantity, 4);

      // Candle has 3 in stock.
      await expectLater(
          app.addToCart(candle.id, 4), throwsA(isA<Exception>()));
      await app.addToCart(candle.id, 3);
      await expectLater(
          app.changeQty(app.cart.last, 4), throwsA(isA<Exception>()));

      expect(app.subtotal, closeTo(4 * 12.50 + 3 * 14.00, 0.001));
      expect(app.total, closeTo(app.subtotal + AppState.deliveryFee, 0.001));

      await app.removeItem(app.cart.last);
      expect(app.cart.length, 1);
    });

    test('out of stock product cannot be added', () async {
      final bottle = app.products.firstWhere((x) => x.name == 'Glass Bottle');
      expect(bottle.stock, 0);
      await expectLater(
          app.addToCart(bottle.id, 1), throwsA(isA<Exception>()));
    });

    test('place order saves items, reduces stock, clears cart', () async {
      final order = await app.placeOrder('Phnom Penh', '098765432');
      expect(order.status, 'Pending');
      expect(order.total, closeTo(4 * 12.50 + AppState.deliveryFee, 0.001));
      expect(app.cart, isEmpty);
      expect(app.orders.length, 1);

      final mug = app.products.firstWhere((x) => x.name == 'Ceramic Mug');
      expect(mug.stock, 12 - 4);

      final items = await DbHelper.instance.getOrderItems(order.id);
      expect(items.single.name, 'Ceramic Mug');
      expect(items.single.quantity, 4);

      final receipt = Exporter.receiptText(order, items);
      expect(receipt, contains('Ceramic Mug'));
      expect(receipt, contains(money(order.total)));

      await expectLater(app.placeOrder('Phnom Penh', '098765432'),
          throwsA(isA<Exception>()));
    });

    test('admin: stats, order status, categories, products', () async {
      await app.logout();
      await app.login('admin@pocketmart.com', 'admin123', false);
      expect(app.user!.isAdmin, isTrue);
      final db = DbHelper.instance;

      final stats = await db.getStats();
      expect(stats.products, 10);
      expect(stats.orders, 7 + 1);
      expect(stats.revenue, closeTo(268.30 + 51.50, 0.001));

      final order = (await db.getOrders()).first; // newest first
      await db.updateOrderStatus(order.id, 'Delivering');
      expect((await db.getOrder(order.id)).status, 'Delivering');
      expect(Exporter.salesReportText(await db.getOrders(), stats),
          contains('Delivering'));

      await db.insertCategory('Toys');
      await expectLater(db.insertCategory('toys'), throwsA(isA<Exception>()));
      await app.loadCatalog();
      final toys = app.categories.firstWhere((c) => c.name == 'Toys');
      await db.updateCategory(toys.id, 'Kids');

      await db.insertProduct({
        'name': 'Wooden Car',
        'price': 8.0,
        'stock': 4,
        'description': 'Toy car',
        'image': 'box',
        'category_id': toys.id,
      });
      await app.loadCatalog();
      final car = app.products.firstWhere((x) => x.name == 'Wooden Car');
      expect(car.categoryName, 'Kids');

      // A category with products cannot be deleted.
      await expectLater(db.deleteCategory(toys.id), throwsA(isA<Exception>()));

      await db.updateProduct(car.id, {'price': 9.5});
      await app.loadCatalog();
      expect(app.products.firstWhere((x) => x.id == car.id).price, 9.5);

      await db.deleteProduct(car.id);
      await db.deleteCategory(toys.id);
      await app.loadCatalog();
      expect(app.products.length, 10);
      expect(app.categories.any((c) => c.id == toys.id), isFalse);
    });
  });

  testWidgets('app opens on the login screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const PocketMartApp());
    // Startup reads the database outside the fake test clock, so wait for it.
    for (var i = 0; i < 50 && find.text(S.welcomeBack).evaluate().isEmpty; i++) {
      await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
    }
    expect(find.text(S.welcomeBack), findsOneWidget);
    expect(find.widgetWithText(FilledButton, S.logIn), findsOneWidget);
  });
}
