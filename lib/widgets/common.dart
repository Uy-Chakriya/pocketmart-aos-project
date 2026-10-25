import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme.dart';
import '../utils.dart';

const Map<String, IconData> productIcons = {
  'mug': Icons.coffee_outlined,
  'bag': Icons.shopping_bag_outlined,
  'cream': Icons.water_drop_outlined,
  'shirt': Icons.checkroom_outlined,
  'plant': Icons.local_florist_outlined,
  'candle': Icons.local_fire_department_outlined,
  'notebook': Icons.menu_book_outlined,
  'bottle': Icons.local_drink_outlined,
  'lamp': Icons.lightbulb_outline,
  'box': Icons.inventory_2_outlined,
};

IconData iconFor(String key) => productIcons[key] ?? Icons.inventory_2_outlined;

/// Photo for a product, e.g. "Ceramic Mug" -> assets/images/products/ceramic_mug.png.
/// Products without a file fall back to their icon.
String productImagePath(String name) =>
    'assets/images/products/${name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_')}.png';

Color tileColor(int id) => AppColors.tiles[id % AppColors.tiles.length];

BoxDecoration cardDecoration({Color color = Colors.white}) => BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    );

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );
}

Color statusFg(String s) {
  switch (s) {
    case 'Delivering':
      return AppColors.info;
    case 'Completed':
      return AppColors.success;
    default:
      return AppColors.warning;
  }
}

Color statusBg(String s) {
  switch (s) {
    case 'Delivering':
      return AppColors.infoBg;
    case 'Completed':
      return AppColors.successBg;
    default:
      return AppColors.warningBg;
  }
}

/// Makes a button fill the available width.
class Wide extends StatelessWidget {
  final Widget child;
  const Wide({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: double.infinity, child: child);
}

class ProductIconBox extends StatelessWidget {
  final String iconKey;
  final String name;
  final int colorId;
  final double iconSize;
  final double radius;

  const ProductIconBox({
    super.key,
    required this.iconKey,
    required this.name,
    required this.colorId,
    this.iconSize = 40,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Center(
      child: Icon(iconFor(iconKey), size: iconSize, color: Colors.white),
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tileColor(colorId),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Image.asset(
        productImagePath(name),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => icon,
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final Color iconColor;
  final double size;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
    this.iconColor = AppColors.ink,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: size * 0.5, color: iconColor),
      ),
    );
  }
}

class QtyStepper extends StatelessWidget {
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  const QtyStepper({
    super.key,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  Widget _btn(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? AppColors.textSecondary : AppColors.ink,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove, onMinus),
          SizedBox(
            width: 28,
            child: Center(
              child: Text('$value',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          _btn(Icons.add, onPlus),
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color fg;
  final Color bg;
  final Widget? trailing;

  const Pill({
    super.key,
    required this.text,
    required this.fg,
    required this.bg,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: TextStyle(
                  color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Status chip. With [onChanged] it opens a menu to change the status.
class StatusChip extends StatelessWidget {
  final String status;
  final ValueChanged<String>? onChanged;

  const StatusChip({super.key, required this.status, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final chip = Pill(
      text: status,
      fg: statusFg(status),
      bg: statusBg(status),
      trailing: onChanged == null
          ? null
          : Icon(Icons.keyboard_arrow_down, size: 14, color: statusFg(status)),
    );
    if (onChanged == null) return chip;
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      onSelected: onChanged,
      itemBuilder: (_) => orderStatuses
          .map((s) => PopupMenuItem<String>(value: s, child: Text(s)))
          .toList(),
      child: chip,
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: bold ? AppColors.ink : AppColors.textSecondary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value,
              style: style.copyWith(
                  color: AppColors.ink,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}

class LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final String? helper;

  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.validator,
    this.suffix,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helper,
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// Subtotal, delivery fee and total.
class SummaryRows extends StatelessWidget {
  final double subtotal;
  final double fee;
  final double total;
  final bool boxed;

  const SummaryRows({
    super.key,
    required this.subtotal,
    required this.fee,
    required this.total,
    this.boxed = false,
  });

  @override
  Widget build(BuildContext context) {
    final rows = Column(
      children: [
        InfoRow(label: S.subtotal, value: money(subtotal)),
        InfoRow(label: S.deliveryFee, value: money(fee)),
        const Divider(height: 16),
        InfoRow(label: S.total, value: money(total), bold: true),
      ],
    );
    if (!boxed) return rows;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: rows,
    );
  }
}
