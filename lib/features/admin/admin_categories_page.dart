part of 'admin_pages.dart';

class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = adminText(context);
    return AdminPageFrame(
      title: t.categoryManagement,
      action: FilledButton.icon(
        onPressed: () => _editCategory(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(t.addCategory),
      ),
      child: ref.watch(adminCategoriesProvider).when(
            loading: () => const BmAdminSkeleton(),
            error: (_, __) => BmEmptyState(
              title: t.unableCategories,
              actionLabel: t.tryAgain,
              onAction: () => ref.invalidate(adminCategoriesProvider),
            ),
            data: (items) => items.isEmpty
                ? BmEmptyState(title: t.noCategories)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final category = items[index];
                      return Card(
                        key: ValueKey(category.id),
                        child: ListTile(
                          leading: const Icon(Icons.category_outlined),
                          title: Text(category.name),
                          subtitle: Text(
                              '${category.nameTamil} · ${t.sortOrder} ${category.sortOrder}'),
                          trailing: BmStatusChip(
                            label: category.isActive ? t.active : t.inactive,
                            tone: category.isActive
                                ? BmStatusTone.success
                                : BmStatusTone.neutral,
                          ),
                          onTap: () =>
                              _editCategory(context, ref, category: category),
                        ),
                      );
                    },
                  ),
          ),
    );
  }

  Future<void> _editCategory(BuildContext context, WidgetRef ref,
      {Category? category}) async {
    final t = adminText(context);
    final name = TextEditingController(text: category?.name ?? '');
    final tamil = TextEditingController(text: category?.nameTamil ?? '');
    final description =
        TextEditingController(text: category?.description ?? '');
    final descriptionTamil =
        TextEditingController(text: category?.descriptionTamil ?? '');
    final image = TextEditingController(text: category?.imageUrl ?? '');
    final sort = TextEditingController(text: '${category?.sortOrder ?? 0}');
    var active = category?.isActive ?? true;
    var saving = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: Text(category == null ? t.addCategory : t.editCategory),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                _RequiredField(controller: name, label: t.categoryNameEnglish),
                const SizedBox(height: 10),
                _RequiredField(controller: tamil, label: t.categoryNameTamil),
                const SizedBox(height: 10),
                TextField(
                  controller: description,
                  decoration: InputDecoration(labelText: t.descriptionEnglish),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionTamil,
                  decoration: InputDecoration(labelText: t.descriptionTamil),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: image,
                  decoration: InputDecoration(labelText: t.imageUrl),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: sort,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: t.sortOrder),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: active,
                  onChanged: (value) => setDialogState(() => active = value),
                  title: Text(t.active),
                ),
              ]),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: saving || name.text.trim().isEmpty
                  ? null
                  : () async {
                      if (category != null && category.isActive != active) {
                        final confirmed = await showDialog<bool>(
                              context: dialogContext,
                              builder: (confirmationContext) => AlertDialog(
                                title: Text(active
                                    ? t.enableCategory
                                    : t.disableCategory),
                                content: Text(active
                                    ? t.enableCategoryMessage
                                    : t.disableCategoryMessage),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                        confirmationContext, false),
                                    child: Text(t.cancel),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(
                                        confirmationContext, true),
                                    child: Text(t.confirm),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                        if (!confirmed) return;
                      }
                      setDialogState(() => saving = true);
                      try {
                        await ref
                            .read(adminRepositoryProvider)
                            .upsertCategory(<String, Object?>{
                          if (category != null) 'id': category.id,
                          'name': name.text.trim(),
                          'nameTamil': tamil.text.trim(),
                          'description': description.text.trim(),
                          'descriptionTamil': descriptionTamil.text.trim(),
                          'imageUrl': image.text.trim(),
                          'sortOrder': int.tryParse(sort.text) ?? 0,
                          'isActive': active,
                        });
                        ref.invalidate(adminCategoriesProvider);
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      } on AdminFailure catch (error) {
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(t.adminError(error.code))),
                          );
                          setDialogState(() => saving = false);
                        }
                      }
                    },
              child: Text(t.save),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    tamil.dispose();
    description.dispose();
    descriptionTamil.dispose();
    image.dispose();
    sort.dispose();
  }
}
