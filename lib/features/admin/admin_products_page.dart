part of 'admin_pages.dart';

class AdminProductsPage extends ConsumerWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = adminText(context);
    final products = ref.watch(adminProductsProvider);
    final categories = ref.watch(adminCategoriesProvider);
    final locations = ref.watch(adminLocationsProvider);
    final ready =
        categories.valueOrNull != null && locations.valueOrNull != null;
    return AdminPageFrame(
      title: t.productManagement,
      action: FilledButton.icon(
        onPressed: ready
            ? () => _openProductEditor(
                  context,
                  ref,
                  categories.valueOrNull!,
                  locations.valueOrNull!,
                )
            : null,
        icon: const Icon(Icons.add_rounded),
        label: Text(t.addProduct),
      ),
      child: products.when(
        loading: () => const BmAdminSkeleton(),
        error: (_, __) => BmEmptyState(
          title: t.unableProducts,
          actionLabel: t.tryAgain,
          onAction: () => ref.invalidate(adminProductsProvider),
        ),
        data: (items) => items.isEmpty
            ? BmEmptyState(title: t.noProducts)
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final product = items[index];
                  return Card(
                    child: ListTile(
                      minTileHeight: 80,
                      leading: SizedBox.square(
                        dimension: 54,
                        child: BmImage(
                          source: product.thumbnail,
                          borderRadius: 10,
                        ),
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        '${product.brand.isEmpty ? product.categoryId : product.brand} · ${t.inventoryLabel(product.inventoryStatus.name)}',
                      ),
                      trailing: Icon(
                        product.isActive
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onTap: ready
                          ? () => _openProductEditor(
                                context,
                                ref,
                                categories.valueOrNull!,
                                locations.valueOrNull!,
                                product: product,
                              )
                          : null,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _openProductEditor(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
    List<DeliveryLocation> locations, {
    Product? product,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _ProductEditor(
          product: product,
          categories: categories,
          locations: locations,
        ),
      ),
    );
    ref.invalidate(adminProductsProvider);
    ref.invalidate(adminDashboardProvider);
  }
}

class _ProductEditor extends ConsumerStatefulWidget {
  const _ProductEditor({
    required this.categories,
    required this.locations,
    this.product,
  });
  final Product? product;
  final List<Category> categories;
  final List<DeliveryLocation> locations;

  @override
  ConsumerState<_ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends ConsumerState<_ProductEditor> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController nameTamil;
  late final TextEditingController description;
  late final TextEditingController descriptionTamil;
  late final TextEditingController brand;
  late final TextEditingController minimum;
  late final TextEditingController stock;
  late final TextEditingController keywords;
  late final TextEditingController specifications;
  late String categoryId;
  late ProductUnit unit;
  late InventoryStatus status;
  late bool active;
  late bool popular;
  late bool featured;
  final priceControllers = <String, TextEditingController>{};
  final initialPrices = <String, num>{};
  Uint8List? imageBytes;
  String? imageName;
  String? imageType;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    name = TextEditingController(text: product?.name ?? '');
    nameTamil = TextEditingController(text: product?.nameTamil ?? '');
    description = TextEditingController(text: product?.description ?? '');
    descriptionTamil =
        TextEditingController(text: product?.descriptionTamil ?? '');
    brand = TextEditingController(text: product?.brand ?? '');
    minimum =
        TextEditingController(text: '${product?.minimumOrderQuantity ?? 1}');
    stock = TextEditingController(text: '${product?.stockQuantity ?? ''}');
    keywords = TextEditingController(text: product?.keywords.join(', ') ?? '');
    specifications = TextEditingController(
      text: product?.specifications.entries
              .map((entry) => '${entry.key}: ${entry.value}')
              .join('\n') ??
          '',
    );
    categoryId = product?.categoryId ??
        (widget.categories.isEmpty ? '' : widget.categories.first.id);
    unit = product?.unit ?? ProductUnit.piece;
    status = product?.inventoryStatus ?? InventoryStatus.available;
    active = product?.isActive ?? true;
    popular = product?.isPopular ?? false;
    featured = product?.isFeatured ?? false;
    for (final location in widget.locations) {
      priceControllers[location.id] = TextEditingController();
    }
    if (product != null) _loadPrices(product.id);
  }

  Future<void> _loadPrices(String productId) async {
    final prices =
        await ref.read(adminRepositoryProvider).currentPrices(productId);
    if (!mounted) return;
    initialPrices.addAll(prices);
    for (final entry in prices.entries) {
      priceControllers[entry.key]?.text = _money(entry.value);
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      name,
      nameTamil,
      description,
      descriptionTamil,
      brand,
      minimum,
      stock,
      keywords,
      specifications,
      ...priceControllers.values,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = adminText(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? t.addProduct : t.editProduct),
        actions: <Widget>[
          TextButton(
            onPressed: saving ? null : _save,
            child: Text(t.save),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: <Widget>[
            Center(
              child: SizedBox(
                width: 220,
                height: 160,
                child: imageBytes == null
                    ? BmImage(source: widget.product?.thumbnail)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(imageBytes!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: OutlinedButton.icon(
                onPressed: saving ? null : _pickImage,
                icon: const Icon(Icons.image_outlined),
                label: Text(t.chooseProductImage),
              ),
            ),
            const SizedBox(height: 16),
            _RequiredField(controller: name, label: t.productNameEnglish),
            const SizedBox(height: 12),
            _RequiredField(controller: nameTamil, label: t.productNameTamil),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: categoryId.isEmpty ? null : categoryId,
              decoration: InputDecoration(labelText: t.category),
              items: <DropdownMenuItem<String>>[
                for (final category in widget.categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
              ],
              validator: (value) => value == null ? t.requiredField : null,
              onChanged: (value) => categoryId = value ?? '',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: description,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(labelText: t.descriptionEnglish),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descriptionTamil,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(labelText: t.descriptionTamil),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: brand,
              decoration: InputDecoration(labelText: t.brand),
            ),
            const SizedBox(height: 12),
            Row(children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<ProductUnit>(
                  initialValue: unit,
                  decoration: InputDecoration(labelText: t.unit),
                  items: <DropdownMenuItem<ProductUnit>>[
                    for (final value in ProductUnit.values)
                      DropdownMenuItem(
                        value: value,
                        child: Text(t.unitLabel(value.name)),
                      ),
                  ],
                  onChanged: (value) => unit = value ?? unit,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: minimum,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: t.minimumOrder),
                  validator: (value) => (int.tryParse(value ?? '') ?? 0) < 1
                      ? t.invalidQuantity
                      : null,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<InventoryStatus>(
                  initialValue: status,
                  decoration: InputDecoration(labelText: t.inventoryStatus),
                  items: <DropdownMenuItem<InventoryStatus>>[
                    for (final value in InventoryStatus.values)
                      DropdownMenuItem(
                        value: value,
                        child: Text(t.inventoryLabel(value.name)),
                      ),
                  ],
                  onChanged: (value) => status = value ?? status,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: stock,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: t.stockQuantity),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: keywords,
              decoration: InputDecoration(labelText: t.searchKeywords),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: specifications,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: t.specifications,
                helperText: t.specificationFormat,
              ),
            ),
            SwitchListTile.adaptive(
              value: active,
              onChanged: (value) => setState(() => active = value),
              title: Text(t.active),
            ),
            SwitchListTile.adaptive(
              value: popular,
              onChanged: (value) => setState(() => popular = value),
              title: Text(t.popularMaterial),
            ),
            SwitchListTile.adaptive(
              value: featured,
              onChanged: (value) => setState(() => featured = value),
              title: Text(t.featuredMaterial),
            ),
            const Divider(height: 32),
            Text(t.locationPricing,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(t.priceHistoryNotice),
            const SizedBox(height: 12),
            for (final location in widget.locations)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: priceControllers[location.id],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '${location.displayName} (${t.currencySymbol})',
                  ),
                ),
              ),
            if (error != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 18),
            BmPrimaryButton(
              label: t.saveProduct,
              loading: saving,
              onPressed: saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 82,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      imageBytes = bytes;
      imageName = file.name;
      imageType = file.mimeType ?? _contentType(file.name);
    });
  }

  Future<void> _save() async {
    if (formKey.currentState?.validate() != true) return;
    if (widget.product != null && widget.product!.isActive != active) {
      final t = adminText(context);
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(active ? t.enableProduct : t.disableProduct),
              content: Text(
                active ? t.enableProductMessage : t.disableProductMessage,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(t.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(t.confirm),
                ),
              ],
            ),
          ) ??
          false;
      if (!confirmed) return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final id = widget.product?.id ??
        'product_${DateTime.now().millisecondsSinceEpoch}';
    try {
      String? imageUrl = widget.product?.thumbnail;
      if (imageBytes != null) {
        imageUrl = await ref.read(productMediaRepositoryProvider).upload(
              productId: id,
              bytes: imageBytes!,
              fileName: imageName ?? 'product.jpg',
              contentType: imageType ?? 'image/jpeg',
            );
      }
      final specs = <String, String>{};
      for (final line in specifications.text.split('\n')) {
        final separator = line.indexOf(':');
        if (separator > 0) {
          specs[line.substring(0, separator).trim()] =
              line.substring(separator + 1).trim();
        }
      }
      await ref.read(adminRepositoryProvider).upsertProduct(<String, Object?>{
        'id': id,
        'name': name.text.trim(),
        'nameTamil': nameTamil.text.trim(),
        'categoryId': categoryId,
        'description': description.text.trim(),
        'descriptionTamil': descriptionTamil.text.trim(),
        'brand': brand.text.trim(),
        'unit': unit.name,
        'minimumOrderQuantity': int.parse(minimum.text),
        'stockStatus': status.name,
        'stockQuantity': int.tryParse(stock.text),
        'keywords': keywords.text
            .split(',')
            .map((value) => value.trim().toLowerCase())
            .where((value) => value.isNotEmpty)
            .toList(),
        'specifications': specs,
        'images': imageUrl == null ? <String>[] : <String>[imageUrl],
        'thumbnail': imageUrl,
        'isPopular': popular,
        'isFeatured': featured,
        'isActive': active,
      });
      for (final location in widget.locations) {
        final price = num.tryParse(priceControllers[location.id]!.text.trim());
        if (price != null && price > 0 && initialPrices[location.id] != price) {
          await ref
              .read(adminRepositoryProvider)
              .setProductPrice(id, location.id, price);
        }
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } on AdminFailure catch (failure) {
      if (mounted) {
        setState(() => error = adminText(context).adminError(failure.code));
      }
    } on ProductMediaFailure catch (failure) {
      if (mounted) {
        setState(() => error = adminText(context).adminError(failure.code));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}
