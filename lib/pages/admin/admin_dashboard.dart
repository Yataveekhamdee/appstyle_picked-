import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../services/firestore_service.dart';
import 'add_product_page.dart';
import 'admin_login_page.dart';
import '../admin/admin_orders.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // อีเมลที่อนุญาตเป็นแอดมิน (ตัวพิมพ์เล็ก)
  static const Set<String> _allowedAdmins = {
    'admin@gmail.com',
    'yatawikhadi@gmail.com',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardAndLoad());
  }

  Future<void> _guardAndLoad() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.toLowerCase() ?? '';
    if (user == null || !_allowedAdmins.contains(email)) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminLoginPage()),
        (_) => false,
      );
      return;
    }
    if (mounted) context.read<ProductProvider>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการสินค้า'),
        actions: [
          IconButton(
            tooltip: 'รีเฟรชสินค้า',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProductProvider>().loadProducts(),
          ),
          PopupMenuButton<String>(
            onSelected: (k) async {
              if (k == 'orders') {
                if (!mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminOrdersPage()),
                );
              } else if (k == 'logout') {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminLoginPage()),
                  (_) => false,
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'orders',
                child: ListTile(
                  leading: Icon(Icons.local_shipping_outlined),
                  title: Text('ออเดอร์ที่ต้องจัดส่ง'),
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('ออกจากระบบ'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (_, p, __) {
          if (p.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (p.error != null) {
            return _Info(
              icon: Icons.error_outline,
              text: 'เกิดข้อผิดพลาด: ${p.error!}',
              actionText: 'ลองใหม่',
              onPressed: p.loadProducts,
            );
          }
          if (p.products.isEmpty) {
            return _Info(
              icon: Icons.inventory_2_outlined,
              text: 'ยังไม่มีสินค้า',
              actionText: 'เพิ่มสินค้า',
              onPressed: _goAddProduct,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: p.products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ProductTile(
              p.products[i],
              onDelete: () => _deleteProduct(p.products[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goAddProduct,
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มสินค้า'),
      ),
    );
  }

  void _goAddProduct() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddProductPage()));
  }

  Future<void> _deleteProduct(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบสินค้า “${p.name}” ใช่ไหม?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ลบ')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await FirestoreService.deleteProduct(p.id);
      if (!mounted) return;
      context.read<ProductProvider>().loadProducts();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('ลบ “${p.name}” แล้ว')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('ลบไม่ได้: $e')));
    }
  }
}

/* === Widgets ย่อย (เรียบ ๆ และสั้น) === */

class _Info extends StatelessWidget {
  const _Info({
    required this.icon,
    required this.text,
    required this.actionText,
    required this.onPressed,
  });

  final IconData icon;
  final String text;
  final String actionText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 60),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onPressed, child: Text(actionText)),
        ]),
      );
}

class _ProductTile extends StatelessWidget {
  const _ProductTile(this.p, {required this.onDelete});
  final Product p;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget img(String path) {
      final fb = const SizedBox(
        width: 56,
        height: 56,
        child: ColoredBox(color: Color(0xFFEDEDED)),
      );
      return path.startsWith('http')
          ? Image.network(path,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fb)
          : Image.asset(path,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fb);
    }

    return Card(
      child: ListTile(
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(8), child: img(p.image)),
        title: Text(p.name,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            
            Text('หมวดหมู่: ${p.categoryName ?? p.category}',
                style: tt.bodySmall),
            const SizedBox(height: 6),
            Text('฿${p.price.toStringAsFixed(0)}',
                style: tt.titleMedium
                    ?.copyWith(color: cs.error, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: IconButton(
          tooltip: 'ลบสินค้า',
          icon: const Icon(Icons.delete),
          color: cs.error,
          onPressed: onDelete,
        ),
      ),
    );
  }
}
