import 'package:flutter/material.dart';

/// ✅ class สำหรับส่งข้อมูลจากหน้าสินค้ามาที่ checkout
class CheckoutArgs {
  final String title;
  final double price;
  final String image; // รองรับทั้ง assets และ http
  final int qty;

  const CheckoutArgs({
    required this.title,
    required this.price,
    required this.image,
    this.qty = 1,
  });
}

/// ✅ หน้าชำระเงิน
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as CheckoutArgs;

    final total = args.price * args.qty;
    final isNet = args.image.startsWith('http');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงสินค้าที่เลือก
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: args.image.isEmpty
                      ? Container(
                          width: 96,
                          height: 96,
                          color: const Color(0xFFEFEFEF),
                          child: const Icon(Icons.image_not_supported),
                        )
                      : isNet
                          ? Image.network(
                              args.image,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 96,
                                height: 96,
                                color: const Color(0xFFEFEFEF),
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                            )
                          : Image.asset(
                              args.image,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 96,
                                height: 96,
                                color: const Color(0xFFEFEFEF),
                                child: const Icon(Icons.image_not_supported_outlined),
                              ),
                            ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(args.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('จำนวน: ${args.qty}',
                          style: const TextStyle(fontSize: 13.5)),
                      const SizedBox(height: 6),
                      Text(
                        '${args.price.toStringAsFixed(0)}.- ฿',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),

            // ที่อยู่จัดส่ง
            const Text('ที่อยู่จัดส่ง',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ชื่อผู้รับ: Yatavee\nที่อยู่: 249 Moo 2, Don Sai, Pak Tho, Ratchaburi 70140\nโทร: 08x-xxx-xxxx',
                style: TextStyle(fontSize: 13.5, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),

            // วิธีชำระเงิน
            const Text('วิธีชำระเงิน',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('เก็บเงินปลายทาง / โอนผ่านธนาคาร / บัตรเครดิต',
                  style: TextStyle(fontSize: 13.5)),
            ),
            const Spacer(),

            // ยอดรวม + ปุ่มชำระเงิน
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ยอดรวม',
                          style: TextStyle(
                              fontSize: 13, color: Colors.black54)),
                      Text(
                        '${total.toStringAsFixed(0)}.- ฿',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ชำระเงินสำเร็จ ขอบคุณที่ใช้บริการ!'),
                        ),
                      );
                    },
                    child: const Text('ชำระเงิน'),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
