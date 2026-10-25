import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/db_helper.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';
import 'admin_categories_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';
import 'order_detail_screen.dart';

class _AdminData {
  final AdminStats stats;
  final List<Order> orders; // all orders, newest first
  const _AdminData(this.stats, this.orders);

  int count(String status) => orders.where((o) => o.status == status).length;
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<_AdminData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_AdminData> _load() async {
    final db = DbHelper.instance;
    return _AdminData(await db.getStats(), await db.getOrders());
  }

  Future<void> _reload() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) _reload();
  }

  Future<void> _changeStatus(Order o, String status) async {
    await DbHelper.instance.updateOrderStatus(o.id, status);
    _reload();
  }

  Future<void> _export(_AdminData data) async {
    try {
      final text = Exporter.salesReportText(data.orders, data.stats);
      final path = await Exporter.saveAndShare('sales_report.txt', text);
      if (mounted) showMessage(context, S.savedTo(path));
    } catch (e) {
      if (mounted) showMessage(context, S.exportFailed(cleanError(e)));
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return S.goodMorning;
    if (h < 18) return S.goodAfternoon;
    return S.goodEvening;
  }

  // ---------- Sections ----------

  Widget _header(AppState app) {
    final u = app.user!;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting()}, ${u.firstName}',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              const Text(S.dashboard,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5)),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: S.logOut,
          offset: const Offset(0, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (_) => app.logout(),
          itemBuilder: (_) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.ink)),
                  Text(u.email,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18, color: AppColors.accent),
                  SizedBox(width: 10),
                  Text(S.logOut, style: TextStyle(color: AppColors.accent)),
                ],
              ),
            ),
          ],
          child: _Avatar(text: u.initials, size: 44, dark: true),
        ),
      ],
    );
  }

  Widget _revenueCard(_AdminData data) {
    final s = data.stats;
    final avg = s.orders == 0 ? 0.0 : s.revenue / s.orders;
    const label = TextStyle(fontSize: 12, color: AppColors.forestText);
    const value = TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text(S.totalRevenue, style: label)),
              _ExportChip(onTap: () => _export(data)),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(money(s.revenue),
                style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                    color: Colors.white)),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.forestLine),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(S.totalOrders, style: label),
                    const SizedBox(height: 2),
                    Text('${s.orders}', style: value),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(S.avgOrder, style: label),
                    const SizedBox(height: 2),
                    Text(money(avg), style: value),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpiRow(_AdminData data, AppState app) {
    final s = data.stats;
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            icon: Icons.inventory_2_outlined,
            value: '${s.products}',
            label: S.totalProducts,
            onTap: () => _open(const AdminProductsScreen()),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            icon: Icons.grid_view_rounded,
            value: '${app.categories.length}',
            label: S.categories,
            onTap: () => _open(const AdminCategoriesScreen()),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            icon: Icons.warning_amber_rounded,
            value: '${s.lowStock}',
            label: S.lowStock,
            warn: s.lowStock > 0,
            onTap: () => _open(const AdminProductsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _statusCard(_AdminData data) {
    final total = data.orders.length;
    final parts = [
      for (final st in orderStatuses) (st, data.count(st)),
    ];

    return _Section(
      title: S.orderStatus,
      trailing: Text(S.ordersCount(total),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: total == 0
                  ? Container(color: AppColors.surfaceMuted)
                  : Row(
                      children: [
                        for (final (st, n) in parts)
                          if (n > 0)
                            Expanded(
                              flex: n,
                              child: Container(
                                margin: const EdgeInsets.only(right: 2),
                                color: statusFg(st),
                              ),
                            ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final (st, n) in parts)
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: statusFg(st), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(st,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ),
                      const SizedBox(width: 4),
                      Text('$n',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _manageCard(_AdminData data, AppState app) {
    return _Section(
      title: S.manage,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _NavRow(
            icon: Icons.inventory_2_outlined,
            title: S.products,
            subtitle: S.productsCount(app.products.length),
            onTap: () => _open(const AdminProductsScreen()),
          ),
          const Divider(height: 1, indent: 66, color: AppColors.border),
          _NavRow(
            icon: Icons.grid_view_rounded,
            title: S.categories,
            subtitle: S.categoriesCount(app.categories.length),
            onTap: () => _open(const AdminCategoriesScreen()),
          ),
          const Divider(height: 1, indent: 66, color: AppColors.border),
          _NavRow(
            icon: Icons.receipt_long_outlined,
            title: S.orders,
            subtitle: S.ordersCount(data.orders.length),
            onTap: () => _open(const AdminOrdersScreen()),
          ),
        ],
      ),
    );
  }

  Widget _restockCard(AppState app) {
    final low = app.products.where((p) => p.stock <= lowStockLimit).toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));

    return _Section(
      title: S.needsRestock,
      trailing: low.isEmpty
          ? null
          : _Link(
              text: S.viewAll,
              onTap: () => _open(const AdminProductsScreen())),
      child: low.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(S.allStocked,
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          : Column(
              children: [
                for (final p in low.take(4))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: ProductIconBox(
                              iconKey: p.image,
                              name: p.name,
                              colorId: p.id,
                              iconSize: 18,
                              radius: 10),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(p.categoryName,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Pill(
                          text: S.unitsLeft(p.stock),
                          fg: p.stock == 0
                              ? AppColors.accent
                              : AppColors.warning,
                          bg: p.stock == 0
                              ? AppColors.accentBg
                              : AppColors.warningBg,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _recentCard(_AdminData data) {
    final recent = data.orders.take(5).toList();
    return _Section(
      title: S.recentOrders,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
      trailing: _Link(
          text: S.viewAll, onTap: () => _open(const AdminOrdersScreen())),
      child: recent.isEmpty
          ? const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(S.noOrders,
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          : Column(
              children: [
                for (var i = 0; i < recent.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 66, color: AppColors.border),
                  _orderRow(recent[i]),
                ],
              ],
            ),
    );
  }

  Widget _orderRow(Order o) {
    return InkWell(
      onTap: () => _open(OrderDetailScreen(order: o)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _Avatar(text: _initials(o.userName), size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('${o.number} · ${formatDay(o.date)}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(money(o.total),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                StatusChip(
                  status: o.status,
                  onChanged: (v) => _changeStatus(o, v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<_AdminData>(
          future: _future,
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cleanError(snap.error!)),
                    const SizedBox(height: 12),
                    OutlinedButton(
                        onPressed: _reload, child: const Text('Retry')),
                  ],
                ),
              );
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snap.data!;

            return RefreshIndicator(
              color: AppColors.forest,
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  _header(app),
                  const SizedBox(height: 20),
                  _revenueCard(data),
                  const SizedBox(height: 12),
                  _kpiRow(data, app),
                  const SizedBox(height: 12),
                  _statusCard(data),
                  const SizedBox(height: 12),
                  _recentCard(data),
                  const SizedBox(height: 12),
                  _restockCard(app),
                  const SizedBox(height: 12),
                  _manageCard(data, app),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------- Small building blocks ----------

/// White card with a title row.
class _Section extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets padding;

  const _Section({
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool warn;
  final VoidCallback onTap;

  const _KpiCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
    this.warn = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = warn ? AppColors.accent : AppColors.ink;
    return Material(
      color: warn ? AppColors.accentBg : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: warn ? AppColors.accentBg : AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(height: 12),
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: fg,
                      letterSpacing: -0.5)),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      color: warn ? AppColors.accent : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: AppColors.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String text;
  final double size;
  final bool dark;

  const _Avatar({required this.text, required this.size, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark ? AppColors.forest : AppColors.sand,
        shape: BoxShape.circle,
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: size * 0.34,
              fontWeight: FontWeight.w700,
              color: dark ? Colors.white : AppColors.ink)),
    );
  }
}

class _ExportChip extends StatelessWidget {
  final VoidCallback onTap;
  const _ExportChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.forestRaised,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_rounded, size: 15, color: Colors.white),
              SizedBox(width: 6),
              Text(S.exportReport,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _Link({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary)),
    );
  }
}
