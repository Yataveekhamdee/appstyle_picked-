import 'package:flutter/material.dart';  //ตะกร้าหน้าว่าง
import '../../providers/cart_store.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ให้ทั้งหน้าฟังการเปลี่ยนแปลงของ cartStore ทีเดียว
    return AnimatedBuilder(
      animation: cartStore,
      builder: (_, __) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('ตะกร้าสินค้า (${cartStore.items.length})'),
          ),

          // ── รายการสินค้าในตะกร้า ─────────────────────────────
          body: cartStore.items.isEmpty
              ? const Center(child: Text('ตะกร้ายังว่างเปล่า'))
              : ListView.separated(
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
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _img(it.image),
                        ),
                        title: Text(
                          it.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '฿${it.price.toStringAsFixed(0)}',
                            style: TextStyle(color: cs.error, fontWeight: FontWeight.w900),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _iconMini(Icons.remove, () => cartStore.dec(it)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text('${it.qty}', style: const TextStyle(fontWeight: FontWeight.w800)),
                            ),
                            _iconMini(Icons.add, () => cartStore.inc(it)),
                            _iconMini(Icons.delete_outline, () => cartStore.remove(it)),
                          ],
                        ),
                      ),
                    );
                  },
                ),

          // ── สรุปราคา + ปุ่มไปชำระเงิน ─────────────────────────
          bottomNavigationBar: SafeArea(
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
                    onPressed: cartStore.items.isEmpty ? null : () => Navigator.pushNamed(context, '/checkout'),
                    child: const Text('ชำระเงิน'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // — helpers ——————————————————————————————————————————————
  Widget _img(String path) {
    const w = 64.0, h = 64.0;
    final fallback = const ColoredBox(color: Color(0xFFEFEFEF));
    if (path.startsWith('http')) {
      return Image.network(path, width: w, height: h, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => SizedBox(width: w, height: h, child: fallback),
      );
    }
    return Image.asset(path, width: w, height: h, fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => SizedBox(width: w, height: h, child: fallback),
    );
  }

  Widget _iconMini(IconData i, VoidCallback onTap) =>
      InkWell(onTap: onTap, child: SizedBox(width: 28, height: 32, child: Icon(i, size: 16)));
}
