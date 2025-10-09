import 'package:flutter/material.dart';
import '../../providers/cart_store.dart';
import '../address/address_form_page.dart'; // ปรับ path ตามที่วางไฟล์

// ===== ที่อยู่จัดส่ง (ค่าตั้งต้น) =====
ShippingAddress _addr = const ShippingAddress(
  name: 'ญาดา  ชาติ',
  phone: '098-002-8979',
  line1: '249 ม.2 ต.คอนสาร',
  district: 'อ.ปากท่อ',
  province: 'จ.ราชบุรี',
  zip: '70140',
);

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ตะกร้าสินค้า (${cartStore.items.length})'), centerTitle: true),

      body: AnimatedBuilder(
        animation: cartStore,
        builder: (_, __) {
          if (cartStore.items.isEmpty) {
            return const Center(child: Text('ตะกร้ายังว่างเปล่า'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
            itemCount: cartStore.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final it = cartStore.items[i];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEAEAEA)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(it.image, width: 64, height: 64, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox(width: 64, height: 64, child: ColoredBox(color: Color(0xFFEFEFEF))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(it.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text('฿${it.price.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900)),
                        ]),
                      ),
                      _Qty(
                        value: it.qty,
                        onInc: () => cartStore.inc(it),
                        onDec: () => cartStore.dec(it),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => cartStore.remove(it),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar: AnimatedBuilder(
        animation: cartStore,
        builder: (_, __) => SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                const Expanded(child: Text('ยอดชำระ', style: TextStyle(fontSize: 12, color: Colors.black54))),
                Text('฿${cartStore.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: cartStore.items.isEmpty ? null : () => Navigator.pushNamed(context, '/checkout'),
                  child: const Text('ชำระเงิน'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Qty extends StatelessWidget {
  final int value;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const _Qty({required this.value, required this.onInc, required this.onDec});

  @override
  Widget build(BuildContext context) => Container(
    height: 32,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE0E0E0))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      _btn(Icons.remove, onDec),
      SizedBox(width: 28, child: Center(child: Text('$value', style: const TextStyle(fontWeight: FontWeight.w800)))),
      _btn(Icons.add, onInc),
    ]),
  );

  Widget _btn(IconData i, VoidCallback onTap) =>
      InkWell(onTap: onTap, child: SizedBox(width: 28, height: 32, child: Icon(i, size: 16)));
}
