import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/admin_auth_provider.dart';
import '../../models/product_model.dart';
import 'add_product_page.dart';
import 'edit_product_page.dart';
import 'admin_login_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    // ตรวจสอบสิทธิ์ Admin และโหลดสินค้า
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminPermission();
    });
  }

  Future<void> _checkAdminPermission() async {
    final adminAuth = context.read<AdminAuthProvider>();
    
    // รอให้ AdminAuthProvider โหลดเสร็จ
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!adminAuth.isLoggedIn || !adminAuth.isAdmin) {
      // ไปที่หน้า Login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminLoginPage()),
        );
      }
      return;
    }
    
    // โหลดสินค้าจาก Firebase
    context.read<ProductProvider>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminAuthProvider>(
      builder: (context, adminAuth, child) {
        // แสดง Loading หรือ Login ถ้าไม่ได้เข้าสู่ระบบ
        if (adminAuth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!adminAuth.isLoggedIn || !adminAuth.isAdmin) {
          return const AdminLoginPage();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('จัดการสินค้า', style: TextStyle(fontWeight: FontWeight.w700)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<ProductProvider>().loadProducts(),
              ),
                  PopupMenuButton<String>(
                    onSelected: _handleMenuAction,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'analytics',
                        child: ListTile(
                          leading: Icon(Icons.analytics),
                          title: Text('Analytics Dashboard'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'products',
                        child: ListTile(
                          leading: Icon(Icons.inventory),
                          title: Text('จัดการสินค้า'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'categories',
                        child: ListTile(
                          leading: Icon(Icons.category),
                          title: Text('จัดการหมวดหมู่'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'brands',
                        child: ListTile(
                          leading: Icon(Icons.business),
                          title: Text('จัดการแบรนด์'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'management',
                        child: ListTile(
                          leading: Icon(Icons.admin_panel_settings),
                          title: Text('จัดการ Admin'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'setup',
                        child: ListTile(
                          leading: Icon(Icons.settings_applications),
                          title: Text('ตั้งค่า Collection'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'profile',
                        child: ListTile(
                          leading: Icon(Icons.person),
                          title: Text('โปรไฟล์'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: ListTile(
                          leading: Icon(Icons.logout, color: Colors.red),
                          title: Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('เกิดข้อผิดพลาด: ${productProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productProvider.loadProducts(),
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          final products = productProvider.products;

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'ยังไม่มีสินค้า',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'กดปุ่ม + เพื่อเพิ่มสินค้าแรก',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // สถิติ
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'สินค้าทั้งหมด',
                        value: products.length.toString(),
                        icon: Icons.inventory_2,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'แบรนด์',
                        value: ProductProvider.availableBrands.length.toString(),
                        icon: Icons.branding_watermark,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // รายการสินค้า
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductCard(
                      product: product,
                      onEdit: () => _navigateToEditProduct(product),
                      onDelete: () => _showDeleteDialog(product),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _navigateToAddProduct,
            icon: const Icon(Icons.add),
            label: const Text('เพิ่มสินค้า'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'analytics':
        Navigator.pushNamed(context, '/admin/analytics');
        break;
      case 'products':
        Navigator.pushNamed(context, '/admin/products');
        break;
      case 'categories':
        Navigator.pushNamed(context, '/admin/categories');
        break;
      case 'brands':
        Navigator.pushNamed(context, '/admin/brands');
        break;
      case 'management':
        Navigator.pushNamed(context, '/admin/management');
        break;
      case 'setup':
        Navigator.pushNamed(context, '/admin/setup');
        break;
      case 'profile':
        _showProfileDialog();
        break;
      case 'logout':
        await _handleLogout();
        break;
    }
  }

  void _showProfileDialog() {
    final adminAuth = context.read<AdminAuthProvider>();
    final user = adminAuth.currentUser;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ข้อมูล Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ชื่อ: ${user?.displayName ?? 'ไม่ระบุ'}'),
            Text('อีเมล: ${user?.email ?? 'ไม่ระบุ'}'),
            Text('UID: ${user?.uid ?? 'ไม่ระบุ'}'),
            Text('สถานะ: ${adminAuth.isAdmin ? 'Admin' : 'User'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบ Admin หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<AdminAuthProvider>().signOut();
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminLoginPage()),
        );
      }
    }
  }

  void _navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductPage()),
    );
  }

  void _navigateToEditProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(product: product),
      ),
    );
  }

  void _showDeleteDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบสินค้า "${product.name}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: เพิ่มฟังก์ชันลบสินค้า
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ลบสินค้า "${product.name}" แล้ว')),
              );
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // รูปสินค้า
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.image.startsWith('http')
                  ? Image.network(
                      product.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Image.asset(
                      product.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // ข้อมูลสินค้า
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'แบรนด์: ${product.brandName ?? product.brand}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'หมวดหมู่: ${product.categoryName ?? product.category}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '฿${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.stock > 10 
                              ? Colors.green[100] 
                              : product.stock > 0 
                                  ? Colors.orange[100] 
                                  : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'สต็อก: ${product.stock}',
                          style: TextStyle(
                            fontSize: 12,
                            color: product.stock > 10 
                                ? Colors.green[700] 
                                : product.stock > 0 
                                    ? Colors.orange[700] 
                                    : Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ปุ่มจัดการ
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'แก้ไข',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'ลบ',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
