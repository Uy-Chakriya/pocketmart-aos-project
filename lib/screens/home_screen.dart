import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _categoryId;
  String _query = '';
  final _searchC = TextEditingController();

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  void _reset() {
    _searchC.clear();
    setState(() {
      _categoryId = null;
      _query = '';
    });
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.ink : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.ink : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.ink,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _tile(Product p, AppState app) {
    final wished = app.wishlist.contains(p.id);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ProductIconBox(
                      iconKey: p.image, name: p.name, colorId: p.id, iconSize: 44),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleIconButton(
                    icon: wished ? Icons.favorite : Icons.favorite_border,
                    iconColor: wished ? AppColors.accent : AppColors.ink,
                    size: 30,
                    onTap: () => app.toggleWishlist(p.id),
                  ),
                ),
                if (p.stock == 0)
                  const Positioned(
                    left: 8,
                    bottom: 8,
                    child: Pill(
                      text: S.outOfStock,
                      fg: AppColors.accent,
                      bg: AppColors.accentBg,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(p.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(money(p.price),
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final q = _query.trim().toLowerCase();
    final items = app.products.where((p) {
      final okCat = _categoryId == null || p.categoryId == _categoryId;
      final okQuery = q.isEmpty || p.name.toLowerCase().contains(q);
      return okCat && okQuery;
    }).toList();
    final filtering = _categoryId != null || q.isNotEmpty;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.hello(app.user!.firstName),
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13)),
                            const Text(S.appName,
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleIconButton(
                            icon: Icons.shopping_bag_outlined,
                            onTap: () => app.setTab(1),
                          ),
                          if (app.cart.isNotEmpty)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                width: 18,
                                height: 18,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                                child: Text('${app.cart.length}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchC,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: S.searchHint,
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      prefixIcon: Icon(Icons.search,
                          size: 20, color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.sand,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(S.bannerTag,
                                  style: TextStyle(
                                      fontSize: 10,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              const Text(S.bannerTitle,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              const Text(S.bannerSub,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _reset,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 34),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                child: const Text(S.shopNow),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.eco_outlined,
                            size: 56, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: app.categories.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return _chip(S.all, _categoryId == null,
                              () => setState(() => _categoryId = null));
                        }
                        final c = app.categories[i - 1];
                        return _chip(c.name, _categoryId == c.id,
                            () => setState(() => _categoryId = c.id));
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(filtering ? S.results : S.popular,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      GestureDetector(
                        onTap: _reset,
                        child: const Text(S.seeAll,
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (items.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text(S.noProducts)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.78,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) => _tile(items[i], app),
              ),
            ),
        ],
      ),
    );
  }
}
