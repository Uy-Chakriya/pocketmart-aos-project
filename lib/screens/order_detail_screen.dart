import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/models.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late final Future<List<OrderItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = DbHelper.instance.getOrderItems(widget.order.id);
  }

  Future<void> _export(List<OrderItem> items) async {
    try {
      final text = Exporter.receiptText(widget.order, items);
      final name = 'receipt_${widget.order.number.substring(1)}.txt';
      final path = await Exporter.saveAndShare(name, text);
      if (mounted) showMessage(context, S.savedTo(path));
    } catch (e) {
      if (mounted) showMessage(context, S.exportFailed(cleanError(e)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<OrderItem>>(
          future: _future,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snap.data!;
            final subtotal = items.fold(0.0, (s, i) => s + i.lineTotal);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.chevron_left,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Text(S.orderTitle(o.number),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatDateTime(o.date),
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                          StatusChip(status: o.status),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: cardDecoration(),
                        child: Column(
                          children: [
                            for (final i in items)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: ProductIconBox(
                                          iconKey: i.image,
                                          name: i.name,
                                          colorId: i.productId,
                                          iconSize: 20,
                                          radius: 10),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(i.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          Text(
                                            S.qtyTimes(
                                                i.quantity, money(i.price)),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color:
                                                    AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(money(i.lineTotal),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _line(Icons.location_on_outlined, o.address),
                            const SizedBox(height: 10),
                            _line(Icons.phone_iphone, o.phone),
                            const SizedBox(height: 10),
                            _line(Icons.payments_outlined, S.cashOnDelivery),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SummaryRows(
                        subtotal: subtotal,
                        fee: o.total - subtotal,
                        total: o.total,
                        boxed: true,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Wide(
                    child: OutlinedButton.icon(
                      onPressed: () => _export(items),
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text(S.exportReceipt),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _line(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
