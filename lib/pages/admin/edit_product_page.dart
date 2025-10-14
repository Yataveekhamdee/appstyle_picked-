import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/brand_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/product_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/simple_network_image_widget.dart';
import 'image_picker_page.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;

  String? _selectedBrandId;
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _descriptionController = TextEditingController(text: widget.product.description ?? '');
    _imageController = TextEditingController(text: widget.product.image);
    
    // ตั้งค่า brand และ category ID จาก product
    _selectedBrandId = widget.product.brandId;
    _selectedCategoryId = widget.product.categoryId;
        
    print('Debug EditProductPage - Product brandId: ${widget.product.brandId}');
    print('Debug EditProductPage - Product categoryId: ${widget.product.categoryId}');
    print('Debug EditProductPage - Selected brandId: $_selectedBrandId');
    print('Debug EditProductPage - Selected categoryId: $_selectedCategoryId');
    
    // โหลดข้อมูลแบรนด์และหมวดหมู่จาก Firebase
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<BrandProvider>().loadBrands();
      await context.read<CategoryProvider>().loadCategories();
      
      // รอให้ข้อมูลโหลดเสร็จแล้วค่อยตั้งค่า values
      _setInitialValues();
    });
  }
  
  void _setInitialValues() {
    final brandProvider = context.read<BrandProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    
    // ตรวจสอบว่า brandId อยู่ใน activeBrands หรือไม่
    if (_selectedBrandId != null && 
        brandProvider.activeBrands.any((brand) => brand.id == _selectedBrandId)) {
      // ค่าเดิมถูกต้องแล้ว
      print('Debug _setInitialValues - Brand ID $_selectedBrandId is valid');
    } else {
      // ถ้าไม่ถูกต้อง ให้เลือกแบรนด์แรก
      if (brandProvider.activeBrands.isNotEmpty) {
        _selectedBrandId = brandProvider.activeBrands.first.id;
        print('Debug _setInitialValues - Set brand to first available: $_selectedBrandId');
      }
    }
    
    // ตรวจสอบว่า categoryId อยู่ใน activeCategories หรือไม่
    if (_selectedCategoryId != null && 
        categoryProvider.activeCategories.any((category) => category.id == _selectedCategoryId)) {
      // ค่าเดิมถูกต้องแล้ว
      print('Debug _setInitialValues - Category ID $_selectedCategoryId is valid');
    } else {
      // ถ้าไม่ถูกต้อง ให้เลือกหมวดหมู่แรก
      if (categoryProvider.activeCategories.isNotEmpty) {
        _selectedCategoryId = categoryProvider.activeCategories.first.id;
        print('Debug _setInitialValues - Set category to first available: $_selectedCategoryId');
      }
    }
    
    // อัปเดต UI
    if (mounted) {
      setState(() {});
    }
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
        title: const Text('แก้ไขสินค้า', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _showDeleteDialog,
            tooltip: 'ลบสินค้า',
          ),
        ],
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
                if (brandProvider.isLoading) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (brandProvider.error != null) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Error: ${brandProvider.error}'),
                        ElevatedButton(
                          onPressed: () => brandProvider.loadBrands(),
                          child: const Text('ลองใหม่'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (brandProvider.activeBrands.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text('ไม่พบข้อมูลแบรนด์'),
                  );
                }
                
                // ตรวจสอบว่า brandId ถูกต้องหรือไม่
                if (_selectedBrandId != null && 
                    !brandProvider.activeBrands.any((brand) => brand.id == _selectedBrandId)) {
                  // ถ้า brandId ไม่ถูกต้อง ให้เลือกแบรนด์แรก
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (brandProvider.activeBrands.isNotEmpty) {
                      setState(() {
                        _selectedBrandId = brandProvider.activeBrands.first.id;
                      });
                    }
                  });
                }
                
                return _buildBrandDropdown(brandProvider);
              },
            ),
            const SizedBox(height: 16),

            // หมวดหมู่
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                if (categoryProvider.isLoading) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (categoryProvider.error != null) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Error: ${categoryProvider.error}'),
                        ElevatedButton(
                          onPressed: () => categoryProvider.loadCategories(),
                          child: const Text('ลองใหม่'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (categoryProvider.activeCategories.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text('ไม่พบข้อมูลหมวดหมู่'),
                  );
                }
                
                // ตรวจสอบว่า categoryId ถูกต้องหรือไม่
                if (_selectedCategoryId != null && 
                    !categoryProvider.activeCategories.any((category) => category.id == _selectedCategoryId)) {
                  // ถ้า categoryId ไม่ถูกต้อง ให้เลือกหมวดหมู่แรก
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (categoryProvider.activeCategories.isNotEmpty) {
                      setState(() {
                        _selectedCategoryId = categoryProvider.activeCategories.first.id;
                      });
                    }
                  });
                }
                
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
                onPressed: _isLoading ? null : _updateProduct,
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
                        'บันทึกการแก้ไข',
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
    final brands = brandProvider.activeBrands;
    
    print('Debug _buildBrandDropdown - Selected brandId: $_selectedBrandId');
    print('Debug _buildBrandDropdown - Available brands: ${brands.map((b) => '${b.id}:${b.name}').toList()}');
    
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
      items: brands.map((brand) {
        return DropdownMenuItem(
          value: brand.id,
          child: Text(brand.name),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryDropdown(CategoryProvider categoryProvider) {
    final categories = categoryProvider.activeCategories;
    
    print('Debug _buildCategoryDropdown - Selected categoryId: $_selectedCategoryId');
    print('Debug _buildCategoryDropdown - Available categories: ${categories.map((c) => '${c.id}:${c.name}').toList()}');
    
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
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
    );
  }

  Future<void> _updateProduct() async {
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
        'updatedAt': DateTime.now(),
      };

      // อัปเดตข้อมูลใน Firebase
      await FirestoreService.updateProduct(widget.product.id, productData);

      // รีเฟรชข้อมูลใน Provider
      context.read<ProductProvider>().loadProducts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('แก้ไขสินค้าสำเร็จ'),
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบสินค้า "${widget.product.name}" หรือไม่?\n\nการดำเนินการนี้ไม่สามารถย้อนกลับได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProduct();
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct() async {
    setState(() => _isLoading = true);

    try {
      // ลบข้อมูลจาก Firebase
      await FirestoreService.deleteProduct(widget.product.id);

      // รีเฟรชข้อมูลใน Provider
      context.read<ProductProvider>().loadProducts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบสินค้า "${widget.product.name}" สำเร็จ'),
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
