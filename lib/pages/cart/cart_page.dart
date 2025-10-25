// lib/pages/cart/cart_page.dart
import 'package:flutter/material.dart'; // ใช้ของ Flutter ทำ UI หน้าตะกร้า
import '../../providers/cart_store.dart'; // เอาตะกร้าสินค้ารวม (cartStore) มาใช้

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // AnimatedBuilder = รีเฟรช UI อัตโนมัติเมื่อ cartStore เปลี่ยน (เช่น เพิ่ม/ลดจำนวน)
      animation: cartStore,
      builder: (_, __) {
        final items = cartStore.items; // ดึงรายการของในตะกร้าตอนนี้

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('ตะกร้าสินค้า (${items.length})'),
           
          ),

          body: items.isEmpty
              
              ? const Center(child: Text('ตะกร้ายังว่างเปล่า'))
             
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
                  // padding ล่างเยอะเพื่อเว้นที่ปุ่ม "ชำระเงิน" ข้างล่าง
                  itemCount: items.length, // มีกี่ชิ้น ก็สร้างกี่แถว
                  itemBuilder: (_, i) {
                    final it = items[i]; // หยิบสินค้าชิ้นที่ i

                    return Card(
                      child: ListTile(
                        // รูปสินค้า
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _img(it.image),
                       
                        ),

                        // ชื่อสินค้า
                        title: Text(
                          it.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis, // ถ้ายาวตัดด้วย ...
                        ),

                        // ราคา (สีแดงเข้ม)
                        subtitle: Text(
                          '฿${it.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        // ปุ่มควบคุมจำนวน / ลบ
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, 
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () => cartStore.dec(it),
                              // ลดจำนวนสินค้า 1 ชิ้น
                            ),
                            Text(
                              '${it.qty}', // จำนวนชิ้นปัจจุบัน
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () => cartStore.inc(it),
                              // เพิ่มจำนวนสินค้า 1 ชิ้น
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: () => cartStore.remove(it),
                              // เอาสินค้าชิ้นนี้ออกจากตะกร้าเลย
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

          // แถบสรุปราคาด้านล่าง + ปุ่มชำระเงิน
          bottomNavigationBar: SafeArea(
            // SafeArea = ดัน UI ให้อยู่เหนือขอบล่างจอ/ติ่งมือถือ
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  const Text('ยอดชำระ'),
                  const Spacer(), // ดันให้ของด้านขวาถูกชิดขอบขวา

                  // ใช้ cartStore.total คือผลรวมราคาทั้งหมดในตะกร้า
                  Text(
                    '฿${cartStore.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),

                  const SizedBox(width: 10),

                  // ปุ่ม "ชำระเงิน"
                  ElevatedButton(
                    onPressed: items.isEmpty
                        ? null // ถ้าตะกร้าว่าง ปุ่มกดไม่ได้
                        : () => Navigator.pushNamed(context, '/checkout'),
                        // ถ้าตะกร้ามีของ -> ไปหน้า /checkout
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

  // _img() = ฟังก์ชันเลือกวิธีโหลดรูปภาพ
  Widget _img(String path) => path.startsWith('http')
      ? Image.network(path, width: 64, height: 64, fit: BoxFit.cover)
      : Image.asset(path,   width: 64, height: 64, fit: BoxFit.cover);
}
