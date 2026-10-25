import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/db_helper.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  Future<void> _form(BuildContext context, {Product? product}) async {
    final app = context.read<AppState>();
    if (app.categories.isEmpty) {
      showMessage(context, S.addCategoryFirst);
      return;
    }
    final formKey = GlobalKey<FormState>();
    final nameC = TextEditingController(text: product?.name ?? '');
    final priceC = TextEditingController(
        text: product == null ? '' : product.price.toStringAsFixed(2));
    final stockC =
        TextEditingController(text: product == null ? '' : '${product.stock}');
    final descC = TextEditingController(text: product?.description ?? '');

    var categoryId = product?.categoryId ?? app.categories.first.id;
    if (!app.categories.any((c) => c.id == categoryId)) {
      categoryId = app.categories.first.id;
    }
    var icon = (product != null && productIcons.containsKey(product.image))
        ? product.image
        : productIcons.keys.first;
    String? error;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(product == null ? S.addProduct : S.editProduct),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameC,
                    decoration: const InputDecoration(labelText: S.productName),
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: categoryId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: S.category),
                    items: app.categories
                        .map((c) => DropdownMenuItem<int>(
                            value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) => categoryId = v ?? categoryId,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: priceC,
                    decoration: const InputDecoration(labelText: S.price),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.price,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: stockC,
                    decoration: const InputDecoration(labelText: S.stock),
                    keyboardType: TextInputType.number,
                    validator: Validators.stock,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: icon,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: S.icon),
                    items: productIcons.entries
                        .map((e) => DropdownMenuItem<String>(
                              value: e.key,
                              child: Row(children: [
                                Icon(e.value, size: 18),
                                const SizedBox(width: 8),
                                Text(e.key),
                              ]),
                            ))
                        .toList(),
                    onChanged: (v) => icon = v ?? icon,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descC,
                    decoration: const InputDecoration(labelText: S.description),
                    maxLines: 3,
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(error!,
                          style: const TextStyle(color: AppColors.accent)),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(S.cancel)),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  final Map<String, Object?> data = {
                    'name': nameC.text.trim(),
                    'price': double.parse(priceC.text.trim()),
                    'stock': int.parse(stockC.text.trim()),
                    'description': descC.text.trim(),
                    'image': icon,
                    'category_id': categoryId,
                  };
                  if (product == null) {
                    await DbHelper.instance.insertProduct(data);
                  } else {
                    await DbHelper.instance.updateProduct(product.id, data);
                  }
                  await app.loadCatalog();
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setLocal(() => error = cleanError(e));
                }
              },
              child: const Text(S.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, Product p) async {
    final app = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.deleteQuestion(p.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(S.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(S.delete)),
        ],
      ),
    );
    if (ok != true) return;
    await DbHelper.instance.deleteProduct(p.id);
    await app.loadCatalog();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<AppState>().products;

    return Scaffold(
      appBar: AppBar(title: const Text(S.products)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        onPressed: () => _form(context),
        child: const Icon(Icons.add),
      ),
      body: products.isEmpty
          ? const Center(child: Text(S.noProducts))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final p = products[i];
                final low = p.stock <= lowStockLimit;
                return Container(
                  decoration: cardDecoration(),
                  child: ListTile(
                    leading: SizedBox(
                      width: 44,
                      height: 44,
                      child: ProductIconBox(
                          iconKey: p.image,
                          name: p.name,
                          colorId: p.id,
                          iconSize: 20,
                          radius: 10),
                    ),
                    title: Text(p.name),
                    subtitle: Text(
                      '${p.categoryName} · ${money(p.price)} · ${p.stock}',
                      style: TextStyle(
                          color: low ? AppColors.accent : AppColors.textSecondary,
                          fontSize: 12),
                    ),
                    onTap: () => _form(context, product: p),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(context, p),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
