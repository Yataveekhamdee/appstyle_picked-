import 'package:flutter/material.dart';
import '../../models/brand_model.dart';
import '../../services/brand_service.dart';
import '../../widgets/simple_network_image_widget.dart';
import 'add_brand_page.dart';
import 'edit_brand_page.dart';

class BrandManagementPage extends StatefulWidget {
  const BrandManagementPage({super.key});

  @override
  State<BrandManagementPage> createState() => _BrandManagementPageState();
}

class _BrandManagementPageState extends State<BrandManagementPage> {
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
        title: const Text('จัดการแบรนด์', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => BrandService.updateAllProductCounts(),
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
                hintText: 'ค้นหาแบรนด์...',
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

          // รายการแบรนด์
          Expanded(
            child: StreamBuilder<List<Brand>>(
              stream: _searchQuery.isEmpty 
                  ? BrandService.watchBrands()
                  : BrandService.searchBrands(_searchQuery),
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

                final brands = snapshot.data ?? [];

                if (brands.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.business, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty 
                              ? 'ยังไม่มีแบรนด์' 
                              : 'ไม่พบแบรนด์ที่ค้นหา',
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
                                builder: (context) => const AddBrandPage(),
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('เพิ่มแบรนด์แรก'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: brands.length,
                  itemBuilder: (context, index) {
                    final brand = brands[index];
                    return _BrandCard(
                      brand: brand,
                      onEdit: () => _navigateToEditBrand(brand),
                      onDelete: () => _showDeleteDialog(brand),
                      onToggleStatus: () => _toggleBrandStatus(brand),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddBrand,
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มแบรนด์'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _navigateToAddBrand() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBrandPage()),
    );
  }

  void _navigateToEditBrand(Brand brand) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBrandPage(brand: brand),
      ),
    );
  }

  void _showDeleteDialog(Brand brand) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบแบรนด์ "${brand.name}" หรือไม่?\n\n${brand.productCount > 0 ? '⚠️ แบรนด์นี้มีสินค้า ${brand.productCount} รายการ' : ''}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteBrand(brand);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBrand(Brand brand) async {
    try {
      await BrandService.deleteBrand(brand.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบแบรนด์ "${brand.name}" เรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถลบแบรนด์ได้: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleBrandStatus(Brand brand) async {
    try {
      await BrandService.toggleBrandStatus(brand.id, !brand.isActive);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${brand.isActive ? 'ปิดใช้งาน' : 'เปิดใช้งาน'} แบรนด์ "${brand.name}" เรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถเปลี่ยนสถานะแบรนด์ได้: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _BrandCard extends StatelessWidget {
  final Brand brand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _BrandCard({
    required this.brand,
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
                // Logo แบรนด์
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: brand.isActive 
                        ? Colors.purple[100] 
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: brand.logo != null && brand.logo!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SimpleSmartImageWidget(
                            imageUrl: brand.logo!,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            errorWidget: Icon(
                              Icons.business,
                              color: brand.isActive 
                                  ? Colors.purple[700] 
                                  : Colors.grey[600],
                              size: 24,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.business,
                          color: brand.isActive 
                              ? Colors.purple[700] 
                              : Colors.grey[600],
                          size: 24,
                        ),
                ),
                const SizedBox(width: 12),

                // ข้อมูลแบรนด์
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              brand.name,
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
                              color: brand.isActive 
                                  ? Colors.green[100] 
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              brand.isActive ? 'ใช้งาน' : 'ปิดใช้งาน',
                              style: TextStyle(
                                fontSize: 12,
                                color: brand.isActive 
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
                        brand.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'สินค้า: ${brand.productCount} รายการ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (brand.website != null && brand.website!.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.link,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                brand.website!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
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
                      brand.isActive ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                    ),
                    label: Text(brand.isActive ? 'ปิด' : 'เปิด'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: brand.isActive 
                          ? Colors.orange[700] 
                          : Colors.green[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: brand.productCount > 0 ? null : onDelete,
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



