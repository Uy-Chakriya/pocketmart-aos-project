import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppState>().orders;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(S.myOrders,
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                Text(S.newestFirst,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: orders.isEmpty
                  ? const Center(child: Text(S.noOrders))
                  : ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final o = orders[i];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => OrderDetailScreen(order: o)),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: cardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(o.number,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    StatusChip(status: o.status),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${formatDay(o.date)} · ${S.itemWord(o.itemCount)}',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12),
                                    ),
                                    Row(
                                      children: [
                                        Text(money(o.total),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700)),
                                        const Icon(Icons.chevron_right,
                                            size: 18,
                                            color: AppColors.textSecondary),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
