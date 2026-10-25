import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  Future<void> _add(AppState app) async {
    try {
      await app.addToCart(widget.product.id, _qty);
      if (mounted) showMessage(context, S.addedToCart);
    } catch (e) {
      if (mounted) showMessage(context, cleanError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    // Use the latest copy so stock stays correct after cart and order changes.
    final p = app.products.firstWhere((x) => x.id == widget.product.id,
        orElse: () => widget.product);
    final inStock = p.stock > 0;
    if (inStock && _qty > p.stock) _qty = p.stock;
    final wished = app.wishlist.contains(p.id);
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 280,
                width: double.infinity,
                color: tileColor(p.id),
                padding: EdgeInsets.only(top: top + 24, bottom: 24),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ProductIconBox(
                        iconKey: p.image,
                        name: p.name,
                        colorId: p.id,
                        iconSize: 96,
                        radius: 24),
                  ),
                ),
              ),
              Positioned(
                top: top + 8,
                left: 16,
                child: CircleIconButton(
                  icon: Icons.chevron_left,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                top: top + 8,
                right: 16,
                child: CircleIconButton(
                  icon: wished ? Icons.favorite : Icons.favorite_border,
                  iconColor: wished ? AppColors.accent : AppColors.ink,
                  onTap: () => app.toggleWishlist(p.id),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.categoryName.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(p.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700)),
                      ),
                      Text(money(p.price),
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  inStock
                      ? Pill(
                          text: S.leftInStock(p.stock),
                          fg: AppColors.success,
                          bg: AppColors.successBg)
                      : const Pill(
                          text: S.outOfStock,
                          fg: AppColors.accent,
                          bg: AppColors.accentBg),
                  const SizedBox(height: 20),
                  const Text(S.description,
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(p.description,
                      style: const TextStyle(
                          color: AppColors.textSecondary, height: 1.5)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(S.quantity,
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(
                            inStock
                                ? S.maxPerOrder(p.stock)
                                : S.currentlyUnavailable,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      QtyStepper(
                        value: inStock ? _qty : 0,
                        onMinus: inStock && _qty > 1
                            ? () => setState(() => _qty--)
                            : null,
                        onPlus: inStock && _qty < p.stock
                            ? () => setState(() => _qty++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  CircleIconButton(
                    icon: wished ? Icons.favorite : Icons.favorite_border,
                    iconColor: wished ? AppColors.accent : AppColors.ink,
                    size: 52,
                    onTap: () => app.toggleWishlist(p.id),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: inStock ? () => _add(app) : null,
                      icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                      label: Text(inStock ? S.addToCart : S.outOfStock),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
