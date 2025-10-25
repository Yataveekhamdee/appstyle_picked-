// lib/pages/admin/add_product_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../services/firestore_service.dart';
import 'image_picker_page.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});
  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
 
  // final _desc = TextEditingController();  // ลบ description ออก

  String? _categoryId, _imageUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CategoryProvider>().loadCategories(),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cats = context.watch<CategoryProvider>().activeCategories;

    // --- ตัวตรวจง่าย ๆ (คืน null = ผ่าน) ---
    String? vReq(String? v) =>
        (v == null || v.trim().isEmpty) ? 'กรุณากรอกข้อมูล' : null;

    String? vPrice(String? v) {
      final d = double.tryParse((v ?? '').trim());
      if (d == null) return 'กรอกราคาเป็นตัวเลข';
      if (d <= 0) return 'ราคาต้องมากกว่า 0';
      return null;
    }

  
    Widget field({
      required TextEditingController c,
      required String label,
      String? hint,
      String? Function(String?)? validator,
      TextInputType? type,
      int maxLines = 1,
    }) =>
        TextFormField(
          controller: c,
          validator: validator,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(labelText: label, hintText: hint),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มสินค้าใหม่')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              const Text(
                'รูปภาพสินค้า',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: const Text('เลือกรูป'),
              ),
            ]),
            const SizedBox(height: 8),

            if ((_imageUrl ?? '').isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imageUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    alignment: Alignment.center,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ชื่อสินค้า
            field(
              c: _name,
              label: 'ชื่อสินค้า',
              hint: 'กรอกชื่อสินค้า',
              validator: vReq,
            ),
            const SizedBox(height: 12),

            // หมวดหมู่
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: const InputDecoration(labelText: 'หมวดหมู่'),
              items: [
                for (final c in cats)
                  DropdownMenuItem(value: c.id, child: Text(c.name))
              ],
              onChanged: (v) => setState(() => _categoryId = v),
              validator: (v) =>
                  v == null || v.isEmpty ? 'กรุณาเลือกหมวดหมู่' : null,
            ),
            const SizedBox(height: 12),

            // ราคา
            field(
              c: _price,
              label: 'ราคา (บาท)',
              hint: '0',
              type: TextInputType.number,
              validator: vPrice,
            ),
            const SizedBox(height: 12),


            // ปุ่มบันทึก
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('บันทึกสินค้า'),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final url = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ImagePickerPage()),
    );
    if (url?.isNotEmpty == true) setState(() => _imageUrl = url);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    if ((_imageUrl ?? '').isEmpty) {
      _snack('กรุณาเลือกรูปสินค้า');
      return;
    }
    if (_categoryId == null) {
      _snack('กรุณาเลือกหมวดหมู่');
      return;
    }

    setState(() => _saving = true);
    try {
      final cats = context.read<CategoryProvider>().activeCategories;
      final categoryName = cats.firstWhere((c) => c.id == _categoryId!).name;
      final now = DateTime.now();

      await FirestoreService.addProduct({
        'name': _name.text.trim(),
        'categoryId': _categoryId,
        'categoryName': categoryName,
        'price': double.parse(_price.text.trim()),
        'image': _imageUrl,
        'createdAt': now,
        'updatedAt': now,
      });

      if (!mounted) return;
      context.read<ProductProvider>().loadProducts();
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } catch (e) {
      if (mounted) _snack('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}
