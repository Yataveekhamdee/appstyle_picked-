import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/brand_provider.dart';
import '../../providers/category_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/simple_network_image_widget.dart';
import 'image_picker_page.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();

  String? _selectedBrandId;
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลแบรนด์และหมวดหมู่
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandProvider>().loadBrands();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มสินค้าใหม่', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // รูปสินค้า
            _buildImageSection(),
            const SizedBox(height: 24),

            // ชื่อสินค้า
            _buildTextField(
              controller: _nameController,
              label: 'ชื่อสินค้า',
              hint: 'กรอกชื่อสินค้า',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกชื่อสินค้า';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // แบรนด์
            Consumer<BrandProvider>(
              builder: (context, brandProvider, child) {
                return _buildBrandDropdown(brandProvider);
              },
            ),
            const SizedBox(height: 16),

            // หมวดหมู่
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                return _buildCategoryDropdown(categoryProvider);
              },
            ),
            const SizedBox(height: 16),

            // ราคา
            _buildTextField(
              controller: _priceController,
              label: 'ราคา (บาท)',
              hint: '0',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกราคา';
                }
                if (double.tryParse(value) == null) {
                  return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                }
                if (double.parse(value) <= 0) {
                  return 'ราคาต้องมากกว่า 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // สต็อก
            _buildTextField(
              controller: _stockController,
              label: 'จำนวนสต็อก',
              hint: '0',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกจำนวนสต็อก';
                }
                if (int.tryParse(value) == null) {
                  return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                }
                if (int.parse(value) < 0) {
                  return 'จำนวนสต็อกต้องมากกว่าหรือเท่ากับ 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // รายละเอียด
            _buildTextField(
              controller: _descriptionController,
              label: 'รายละเอียดสินค้า',
              hint: 'กรอกรายละเอียดสินค้า',
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // ปุ่มบันทึก
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'บันทึกสินค้า',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 100), // สำหรับ FAB
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'รูปภาพสินค้า',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _selectImage,
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: const Text('เลือกรูป'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _imageController,
            label: 'URL รูปภาพ หรือ Path รูปภาพ',
            hint: 'assets/images/brand/product.jpg หรือ https://example.com/image.jpg',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอก URL หรือ path รูปภาพ';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          if (_imageController.text.isNotEmpty)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SimpleSmartImageWidget(
                  imageUrl: _imageController.text,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      onChanged: (value) {
        if (label == 'URL รูปภาพ หรือ Path รูปภาพ') {
          setState(() {}); // รีเฟรช UI เพื่อแสดงรูปภาพ
        }
      },
    );
  }

  Widget _buildBrandDropdown(BrandProvider brandProvider) {
    return DropdownButtonFormField<String>(
      value: _selectedBrandId,
      onChanged: (value) => setState(() => _selectedBrandId = value),
      decoration: InputDecoration(
        labelText: 'แบรนด์',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณาเลือกแบรนด์';
        }
        return null;
      },
      items: brandProvider.activeBrands.map((brand) {
        return DropdownMenuItem(
          value: brand.id,
          child: Text(brand.name),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryDropdown(CategoryProvider categoryProvider) {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      onChanged: (value) => setState(() => _selectedCategoryId = value),
      decoration: InputDecoration(
        labelText: 'หมวดหมู่',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณาเลือกหมวดหมู่';
        }
        return null;
      },
      items: categoryProvider.activeCategories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final productData = {
        'name': _nameController.text.trim(),
        'brandId': _selectedBrandId,
        'categoryId': _selectedCategoryId,
        'price': double.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'image': _imageController.text.trim(),
        'description': _descriptionController.text.trim(),
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      // บันทึกข้อมูลลง Firebase
      await FirestoreService.addProduct(productData);

      // รีเฟรชข้อมูลใน Provider
      context.read<ProductProvider>().loadProducts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เพิ่มสินค้าสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectImage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePickerPage(initialImage: _imageController.text),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        _imageController.text = result;
      });
    }
  }
}
