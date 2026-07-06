import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/permissions/app_permission.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/image_service.dart';
import '../../data/models/product.dart';
import '../../data/products_repository.dart';
import '../../widgets/app_buttons.dart';

/// Full-screen add/edit product form with multi-image upload to Storage.
class ProductFormScreen extends StatefulWidget {
  final Product? existing;
  const ProductFormScreen({super.key, this.existing});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _desc = TextEditingController(text: widget.existing?.description);
  late final _benefit = TextEditingController(text: widget.existing?.benefit);
  late final _price =
      TextEditingController(text: _num(widget.existing?.price));
  late final _mrp = TextEditingController(text: _num(widget.existing?.mrp));
  late final _stock =
      TextEditingController(text: widget.existing?.stock.toString() ?? '');

  late bool _active = widget.existing?.active ?? true;
  late final List<String> _existingImages = [...?widget.existing?.imageUrls];
  final List<XFile> _newImages = [];
  bool _saving = false;

  static String _num(double? v) =>
      (v == null || v == 0) ? '' : v.toStringAsFixed(0);

  @override
  void dispose() {
    for (final c in [_name, _desc, _benefit, _price, _mrp, _stock]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pick() async {
    // Check photo access only at the moment it's needed (no-op on web).
    final granted = await PermissionService.instance
        .ensure(context, AppPermission.photos);
    if (!granted) return;
    try {
      final files = await ImageService.instance.pick();
      if (files.isNotEmpty) setState(() => _newImages.addAll(files));
    } catch (e) {
      if (mounted) _toast('Could not open the image picker: $e');
    }
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    if (_existingImages.isEmpty && _newImages.isEmpty) {
      _toast('Add at least one product image.');
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ProductsRepository.instance;
      final id = widget.existing?.id ?? repo.newId();
      final uploaded =
          await ImageService.instance.uploadAll(id, _newImages);
      final product = Product(
        id: id,
        name: _name.text.trim(),
        description: _desc.text.trim(),
        benefit: _benefit.text.trim(),
        imageUrls: [..._existingImages, ...uploaded],
        price: double.tryParse(_price.text.trim()) ?? 0,
        mrp: double.tryParse(_mrp.text.trim()) ?? 0,
        stock: int.tryParse(_stock.text.trim()) ?? 0,
        active: _active,
      );
      await repo.update(id, product);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _toast('Save failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Images',
                      style: AppTextStyles.h3
                          .copyWith(color: brand.textPrimary, fontSize: 16)),
                  const SizedBox(height: AppDimens.sm),
                  _imageRow(brand),
                  const SizedBox(height: AppDimens.lg),
                  _field(_name, 'Product name'),
                  _field(_desc, 'Short description', maxLines: 2),
                  _field(_benefit, 'Key benefit', maxLines: 2),
                  Row(children: [
                    Expanded(
                        child: _field(_price, 'Price (₹)',
                            number: true, required: true)),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                        child: _field(_mrp, 'MRP (₹, optional)',
                            number: true, required: false)),
                  ]),
                  _field(_stock, 'Stock quantity', number: true),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active (visible to customers)'),
                    value: _active,
                    activeThumbColor: AppColors.primaryGreen,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                  const SizedBox(height: AppDimens.md),
                  _saving
                      ? const Center(child: CircularProgressIndicator())
                      : PrimaryButton(
                          text: 'Save Product',
                          icon: Icons.save_outlined,
                          onPressed: _save),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageRow(BrandColors brand) {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (int i = 0; i < _existingImages.length; i++)
            _thumb(
              child: CachedNetworkImage(
                  imageUrl: _existingImages[i], fit: BoxFit.cover),
              onRemove: () => setState(() => _existingImages.removeAt(i)),
            ),
          for (int i = 0; i < _newImages.length; i++)
            _thumb(
              child: Image.network(_newImages[i].path, fit: BoxFit.cover),
              onRemove: () => setState(() => _newImages.removeAt(i)),
            ),
          // Add button
          InkWell(
            onTap: _pick,
            child: Container(
              width: 88,
              height: 88,
              margin: const EdgeInsets.only(right: AppDimens.sm),
              decoration: BoxDecoration(
                color: brand.cardSoft,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.4)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      color: AppColors.primaryGreen),
                  SizedBox(height: 4),
                  Text('Add', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb({required Widget child, required VoidCallback onRemove}) {
    return Container(
      width: 88,
      height: 88,
      margin: const EdgeInsets.only(right: AppDimens.sm),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: child,
          ),
          Positioned(
            top: 2,
            right: 2,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded,
                    size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {bool number = false, bool required = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        inputFormatters: number
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
            : null,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
