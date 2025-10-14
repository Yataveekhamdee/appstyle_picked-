import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';
import 'add_category_page.dart';
import 'edit_category_page.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการหมวดหมู่', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => CategoryService.updateAllProductCounts(),
          ),
        ],
      ),
      body: Column(
        children: [
          // แถบค้นหา
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ค้นหาหมวดหมู่...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // รายการหมวดหมู่
          Expanded(
            child: StreamBuilder<List<Category>>(
              stream: _searchQuery.isEmpty 
                  ? CategoryService.watchCategories()
                  : CategoryService.searchCategories(_searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('ลองใหม่'),
                        ),
                      ],
                    ),
                  );
                }

                final categories = snapshot.data ?? [];

                if (categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty 
                              ? 'ยังไม่มีหมวดหมู่' 
                              : 'ไม่พบหมวดหมู่ที่ค้นหา',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddCategoryPage(),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('เพิ่มหมวดหมู่แรก'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _CategoryCard(
                      category: category,
                      onEdit: () => _navigateToEditCategory(category),
                      onDelete: () => _showDeleteDialog(category),
                      onToggleStatus: () => _toggleCategoryStatus(category),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddCategory,
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มหมวดหมู่'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _navigateToAddCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCategoryPage()),
    );
  }

  void _navigateToEditCategory(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryPage(category: category),
      ),
    );
  }

  void _showDeleteDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบหมวดหมู่ "${category.name}" หรือไม่?\n\n${category.productCount > 0 ? '⚠️ หมวดหมู่นี้มีสินค้า ${category.productCount} รายการ' : ''}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCategory(category);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    try {
      await CategoryService.deleteCategory(category.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบหมวดหมู่ "${category.name}" เรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถลบหมวดหมู่ได้: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleCategoryStatus(Category category) async {
    try {
      await CategoryService.toggleCategoryStatus(category.id, !category.isActive);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category.isActive ? 'ปิดใช้งาน' : 'เปิดใช้งาน'} หมวดหมู่ "${category.name}" เรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถเปลี่ยนสถานะหมวดหมู่ได้: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // ไอคอนหมวดหมู่
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: category.isActive 
                        ? Colors.blue[100] 
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.category,
                    color: category.isActive 
                        ? Colors.blue[700] 
                        : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // ข้อมูลหมวดหมู่
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // สถานะ
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: category.isActive 
                                  ? Colors.green[100] 
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              category.isActive ? 'ใช้งาน' : 'ปิดใช้งาน',
                              style: TextStyle(
                                fontSize: 12,
                                color: category.isActive 
                                    ? Colors.green[700] 
                                    : Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'สินค้า: ${category.productCount} รายการ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ปุ่มจัดการ
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('แก้ไข'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onToggleStatus,
                    icon: Icon(
                      category.isActive ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                    ),
                    label: Text(category.isActive ? 'ปิด' : 'เปิด'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: category.isActive 
                          ? Colors.orange[700] 
                          : Colors.green[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: category.productCount > 0 ? null : onDelete,
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('ลบ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
