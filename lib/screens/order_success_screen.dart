import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';

class OrderSuccessScreen extends StatelessWidget {
  final Order order;
  const OrderSuccessScreen({super.key, required this.order});

  void _goTo(BuildContext context, int tab) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    context.read<AppState>().setTab(tab);
  }

  @override
  Widget build(BuildContext context) {
    final name = context.read<AppState>().user!.firstName;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 56),
                      Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          color: AppColors.sage,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            size: 44, color: AppColors.success),
                      ),
                      const SizedBox(height: 20),
                      const Text(S.orderPlaced,
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(S.thankYou(name),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: cardDecoration(),
                        child: Column(
                          children: [
                            InfoRow(label: S.orderNumber, value: order.number),
                            InfoRow(
                                label: S.date, value: formatDay(order.date)),
                            const InfoRow(
                                label: S.payment, value: S.cashOnDelivery),
                            const Divider(height: 16),
                            InfoRow(
                                label: S.total,
                                value: money(order.total),
                                bold: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Wide(
                child: FilledButton(
                  onPressed: () => _goTo(context, 2),
                  child: const Text(S.viewMyOrders),
                ),
              ),
              const SizedBox(height: 10),
              Wide(
                child: OutlinedButton(
                  onPressed: () => _goTo(context, 0),
                  child: const Text(S.continueShopping),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
