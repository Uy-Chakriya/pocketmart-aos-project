import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/db_helper.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../strings.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  Future<void> _form(BuildContext context, {Category? category}) {
    final app = context.read<AppState>();
    final nameC = TextEditingController(text: category?.name ?? '');
    final formKey = GlobalKey<FormState>();
    String? error;

    return showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(category == null ? S.addCategory : S.editCategory),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameC,
                  decoration:
                      const InputDecoration(labelText: S.categoryName),
                  validator: Validators.required,
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
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(S.cancel)),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  final name = nameC.text.trim();
                  if (category == null) {
                    await DbHelper.instance.insertCategory(name);
                  } else {
                    await DbHelper.instance.updateCategory(category.id, name);
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

  Future<void> _delete(BuildContext context, Category c) async {
    final app = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.deleteQuestion(c.name)),
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
    try {
      await DbHelper.instance.deleteCategory(c.id);
      await app.loadCatalog();
    } catch (e) {
      if (context.mounted) showMessage(context, cleanError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = context.watch<AppState>().categories;

    return Scaffold(
      appBar: AppBar(title: const Text(S.categories)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        onPressed: () => _form(context),
        child: const Icon(Icons.add),
      ),
      body: cats.isEmpty
          ? const Center(child: Text(S.noCategories))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final c = cats[i];
                return Container(
                  decoration: cardDecoration(),
                  child: ListTile(
                    title: Text(c.name),
                    onTap: () => _form(context, category: c),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(context, c),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
