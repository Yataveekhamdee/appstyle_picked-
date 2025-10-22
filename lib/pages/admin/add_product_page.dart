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
  final _form  = GlobalKey<FormState>();
  final _name  = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _desc  = TextEditingController();

  String? _categoryId;
  String? _imageUrl;          // ได้จากหน้า ImagePickerPage
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final categories = context.watch<CategoryProvider>().activeCategories;

    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มสินค้าใหม่')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // รูปภาพสินค้า
            Row(children: [
              const Text('รูปภาพสินค้า', style: TextStyle(fontWeight: FontWeight.w600)),
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

            // ข้อมูลสินค้า
            _field(controller: _name, label: 'ชื่อสินค้า', hint: 'กรอกชื่อสินค้า', validator: _req),
            const SizedBox(height: 12),

            // หมวดหมู่ (ดึงจาก Firestore)
            DropdownButtonFormField<String>(
              value: _categoryId,
              items: [
                for (final c in categories)
                  DropdownMenuItem(value: c.id, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
              validator: _req,
              decoration: const InputDecoration(labelText: 'หมวดหมู่'),
            ),
            const SizedBox(height: 12),

            _field(
              controller: _price,
              label: 'ราคา (บาท)',
              hint: '0',
              keyboardType: TextInputType.number,
              validator: _priceGt0,
            ),
            const SizedBox(height: 12),

            _field(
              controller: _stock,
              label: 'จำนวนสต็อก',
              hint: '0',
              keyboardType: TextInputType.number,
              validator: _stockGte0,
            ),
            const SizedBox(height: 12),

            _field(
              controller: _desc,
              label: 'รายละเอียด (ไม่บังคับ)',
              hint: 'จุดเด่น/รายละเอียดเพิ่มเติม',
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('บันทึกสินค้า'),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ---------- Helpers ----------
  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอกข้อมูล' : null;

  String? _priceGt0(String? v) {
    final d = double.tryParse(v ?? '');
    if (d == null) return 'กรอกราคาเป็นตัวเลข';
    if (d <= 0) return 'ราคาต้องมากกว่า 0';
    return null;
  }

  String? _stockGte0(String? v) {
    final n = int.tryParse(v ?? '');
    if (n == null) return 'กรอกสต็อกเป็นตัวเลข';
    if (n < 0) return 'สต็อกต้องไม่ติดลบ';
    return null;
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  // ---------- Actions ----------
  Future<void> _pickImage() async {
    final url = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ImagePickerPage()),
    );
    if (url != null && url.isNotEmpty) setState(() => _imageUrl = url);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if ((_imageUrl ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาเลือกรูปสินค้า')));
      return;
    }

    setState(() => _saving = true);
    try {
      // ชื่อหมวดหมู่สำหรับแสดงผล (product list จะโชว์สวย)
      final cats = context.read<CategoryProvider>().activeCategories;
      final categoryName = cats.firstWhere((c) => c.id == _categoryId).name;

      final now = DateTime.now();
      await FirestoreService.addProduct({
        'name'         : _name.text.trim(),
        'categoryId'   : _categoryId,
        'categoryName' : categoryName,
        'price'        : double.parse(_price.text),
        'stock'        : int.parse(_stock.text),
        'image'        : _imageUrl,
        'description'  : _desc.text.trim(),
        'createdAt'    : now,
        'updatedAt'    : now,
        
      });

      if (!mounted) return;
      context.read<ProductProvider>().loadProducts();
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
