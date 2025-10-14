import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/admin_auth_provider.dart';
import '../../models/product_model.dart';
import 'add_product_page.dart';
import 'edit_product_page.dart';
import 'admin_login_page.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminPermission();
    });
  }

  Future<void> _checkAdminPermission() async {
    final adminAuth = context.read<AdminAuthProvider>();
    
    if (!adminAuth.isLoggedIn || !adminAuth.isAdmin) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminLoginPage()),
        );
      }
      return;
    }
    
    context.read<ProductProvider>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminAuthProvider>(
      builder: (context, adminAuth, child) {
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
            ],
          ),
          body: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (productProvider.error != null) {
                return Center(child: Text('Error: ${productProvider.error}'));
              }
              final products = productProvider.products;
              if (products.isEmpty) {
                return const Center(child: Text('No products found.'));
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('สินค้าทั้งหมด: ${products.length} รายการ', 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
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

  void _navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductPage()),
    );
  }

  void _navigateToEditProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProductPage(product: product)),
    );
  }

  void _showDeleteDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบสินค้า "${product.name}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<ProductProvider>().deleteProduct(product.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('สินค้าถูกลบแล้ว')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('เกิดข้อผิดพลาดในการลบ: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('ลบ'),
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: product.image.startsWith('http')
            ? Image.network(product.image, width: 50, height: 50, fit: BoxFit.cover)
            : Image.asset(product.image, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(product.name),
        subtitle: Text('Brand: ${product.brand}, Price: ฿${product.price.toStringAsFixed(0)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}



