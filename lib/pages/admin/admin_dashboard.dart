// lib/pages/admin/admin_dashboard.dart
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
  // อีเมลแอดมิน (ตัวพิมพ์เล็ก)
  static const _admins = {'admin@gmail.com', 'yatawikhadi@gmail.com'};

  @override
  void initState() {
    super.initState();
    // เช็คสิทธิ์ → ไม่ใช่เด้งไปหน้า login, ถ้าใช่ค่อยโหลดสินค้า
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final u = FirebaseAuth.instance.currentUser;
      final ok = u != null && _admins.contains((u.email ?? '').toLowerCase());
      if (!ok) {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminLoginPage()),
            (_) => false);
      } else {
        context.read<ProductProvider>().loadProducts();
      }
    });
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductProvider>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // ------- helpers ภายใน build เพื่อลดบรรทัด -------
    Widget info(IconData i, String t, [String? btn, VoidCallback? onTap]) =>
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(i, size: 60),
            const SizedBox(height: 8),
            Text(t, textAlign: TextAlign.center),
            if (btn != null && onTap != null) ...[
              const SizedBox(height: 8),
              ElevatedButton(onPressed: onTap, child: Text(btn)),
            ],
          ]),
        );

    Widget tile(Product x) {
      Widget img(String path) {
        const fb = SizedBox(
            width: 56, height: 56, child: ColoredBox(color: Color(0xFFEDEDED)));
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
              borderRadius: BorderRadius.circular(8), child: img(x.image)),
          title: Text(x.name,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          subtitle:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 2),
            Text('หมวดหมู่: ${x.categoryName ?? x.category}',
                style: tt.bodySmall),
            const SizedBox(height: 6),
            Text('฿${x.price.toStringAsFixed(0)}',
                style: tt.titleMedium
                    ?.copyWith(color: cs.error, fontWeight: FontWeight.bold)),
          ]),
          trailing: IconButton(
            tooltip: 'ลบสินค้า',
            icon: const Icon(Icons.delete),
            color: cs.error,
            onPressed: () => _confirmDelete(x),
          ),
        ),
      );
    }

    // ---------------- UI หลัก ----------------
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminOrdersPage()));
              } else if (k == 'logout') {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminLoginPage()),
                    (_) => false);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'orders',
                child: ListTile(
                    leading: Icon(Icons.local_shipping_outlined),
                    title: Text('ออเดอร์ที่ต้องจัดส่ง')),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                    leading: Icon(Icons.logout), title: Text('ออกจากระบบ')),
              ),
            ],
          ),
        ],
      ),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (p.error != null)
              ? info(Icons.error_outline, 'เกิดข้อผิดพลาด: ${p.error!}',
                  'ลองใหม่', p.loadProducts)
              : (p.products.isEmpty)
                  ? info(Icons.inventory_2_outlined, 'ยังไม่มีสินค้า',
                      'เพิ่มสินค้า', _goAdd)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      itemCount: p.products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => tile(p.products[i]),
                    ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _goAdd,
          icon: const Icon(Icons.add),
          label: const Text('เพิ่มสินค้า')),
    );
  }

  void _goAdd() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddProductPage()));
  }

  Future<void> _confirmDelete(Product p) async {
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
      _snack('ลบ “${p.name}” แล้ว');
    } catch (e) {
      if (!mounted) return;
      _snack('ลบไม่ได้: $e');
    }
  }
}
