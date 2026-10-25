import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/models.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';
import 'order_detail_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  late Future<List<Order>> _future;

  @override
  void initState() {
    super.initState();
    _future = DbHelper.instance.getOrders();
  }

  void _reload() =>
      setState(() => _future = DbHelper.instance.getOrders());

  Future<void> _changeStatus(Order o, String status) async {
    await DbHelper.instance.updateOrderStatus(o.id, status);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(S.allOrders)),
      body: FutureBuilder<List<Order>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snap.data!;
          if (orders.isEmpty) return const Center(child: Text(S.noOrders));
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.number,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            Text(
                              '${o.userName} · ${money(o.total)}\n${formatDateTime(o.date)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      StatusChip(
                        status: o.status,
                        onChanged: (v) => _changeStatus(o, v),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
