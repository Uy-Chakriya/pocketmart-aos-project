import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _change(BuildContext context, CartItem item, int qty) async {
    try {
      await context.read<AppState>().changeQty(item, qty);
    } catch (e) {
      if (context.mounted) showMessage(context, cleanError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = app.cart;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(S.myCart,
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                Text(S.itemsCount(items.length),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shopping_bag_outlined,
                              size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          const Text(S.cartEmpty),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () => app.setTab(0),
                            child: const Text(S.continueShopping),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final item = items[i];
                        final p = item.product;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: cardDecoration(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 64,
                                height: 64,
                                child: ProductIconBox(
                                    iconKey: p.image,
                                    name: p.name,
                                    colorId: p.id,
                                    iconSize: 28,
                                    radius: 12),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Text(money(p.price),
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13)),
                                    const SizedBox(height: 8),
                                    QtyStepper(
                                      value: item.quantity,
                                      onMinus: item.quantity > 1
                                          ? () => _change(
                                              context, item, item.quantity - 1)
                                          : null,
                                      onPlus: item.quantity < p.stock
                                          ? () => _change(
                                              context, item, item.quantity + 1)
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 20, color: AppColors.textSecondary),
                                onPressed: () => app.removeItem(item),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 8),
              SummaryRows(
                subtotal: app.subtotal,
                fee: AppState.deliveryFee,
                total: app.total,
              ),
              const SizedBox(height: 12),
              Wide(
                child: FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  ),
                  child: const Text(S.checkout),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
