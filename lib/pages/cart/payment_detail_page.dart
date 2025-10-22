// lib/pages/checkout/payment_detail_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../providers/cart_store.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentDetailPage extends StatefulWidget {
  const PaymentDetailPage({super.key});
  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  XFile? _slip; // เก็บไฟล์สลิป

  Future<String?> _ensureSignedIn(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) return user.uid;
    Navigator.pushNamed(context, '/login', arguments: {
      'redirect': '/paymentDetail',
      'data': ModalRoute.of(context)?.settings.arguments,
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // 1) รับ arguments แบบตรงไปตรงมา
    final raw = ModalRoute.of(context)?.settings.arguments;
    final args =
        (raw is Map) ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    double asNum(v) => (v is num) ? v.toDouble() : 0.0;

    final itemsTotal = asNum(args['itemsTotal']);
    final shippingFee = asNum(args['shippingFee']);
    final discount = asNum(args['discount']);
    final grandTotal = (args['grandTotal'] as num?)?.toDouble() ??
        (itemsTotal + shippingFee - discount);
    final methodLabel = (args['methodLabel'] as String?) ?? 'Mobile Banking';

    final a = (args['address'] as Map?) ?? const {};
    final name = (a['name'] ?? 'ชื่อผู้รับ').toString();
    final phone = (a['phone'] ?? '').toString();
    final line1 = (a['line1'] ?? '').toString();
    final district = (a['district'] ?? '').toString();
    final province = (a['province'] ?? '').toString();
    final zip = (a['zip'] ?? '').toString();

    String _now() {
      final t = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(t.day)}/${two(t.month)}/${t.year}  ${two(t.hour)}:${two(t.minute)}';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดการชำระเงิน')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(name),
              subtitle: Text('$line1\n$district  $province  $zip\n$phone'),
              trailing: const Chip(label: Text('จัดส่ง')),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                _row('ราคาสินค้า', '฿${itemsTotal.toStringAsFixed(0)}'),
                _row('ส่วนลด',
                    discount == 0 ? '—' : '-฿${discount.toStringAsFixed(0)}'),
                _row(
                    'ค่าจัดส่ง',
                    shippingFee == 0
                        ? 'ฟรี'
                        : '฿${shippingFee.toStringAsFixed(0)}'),
                const Divider(),
                _rowBold('ยอดชำระรวม', '฿${grandTotal.toStringAsFixed(0)}'),
              ]),
            ),
          ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('สแกนชำระเงิน (QR โอนเงิน)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 1, // ให้เป็นสี่เหลี่ยมจัตุรัส
                      child: Image.asset(
                        'assets/images/qr/qr.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 40),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),


          // แนบสลิป (ไม่บังคับ)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final x = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (x != null) setState(() => _slip = x);
                    },
                    icon: const Icon(Icons.upload_file),
                    label: Text(_slip == null ? 'เลือกสลิป' : 'เปลี่ยนสลิป'),
                  ),
                  const SizedBox(width: 12),
                  if (_slip != null)
                    Expanded(
                      child: Text(_slip!.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('ช่องทางการชำระเงิน'),
              subtitle: Text(methodLabel),
              trailing: Text('฿${grandTotal.toStringAsFixed(2)}'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(_now()),
            ),
          ),
        ],
      ),

      // 3) ปุ่มยืนยัน: ล็อกอิน -> สร้างออเดอร์ -> (อัปโหลดสลิปถ้ามี) -> เคลียร์ตะกร้า -> ไปหน้าถัดไป
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: cartStore.items.isEmpty
                  ? null
                  : () async {
                      final uid = await _ensureSignedIn(context);
                      if (uid == null) return;

                      try {
                        // 1) เตรียม items
                        final items = cartStore.items
                            .map((e) => {
                                  'productId': e.productId,
                                  'title': e.title,
                                  'image': e.image,
                                  'price': e.price,
                                  'qty': e.qty,
                                })
                            .toList();

                        // 2) สร้างออเดอร์ (ยังไม่มี slipUrl)
                        final orderId = await FirestoreService.createOrder(
                          items: items,
                          address: {
                            'name': name,
                            'line1': line1,
                            'district': district,
                            'province': province,
                            'zip': zip,
                            'phone': phone,
                          },
                          itemsTotal: itemsTotal,
                          shippingFee: shippingFee,
                          grandTotal: grandTotal,
                          paymentMethod: methodLabel,
                          status: 'pending',
                          userId: uid,
                        );

                        // 3) ถ้ามีสลิป → อัปโหลด แล้วอัปเดตออเดอร์
                        if (_slip != null) {
                          final ref = FirebaseStorage.instance
                              .ref()
                              .child('orders/$orderId/slip.jpg');
                          await ref.putData(await _slip!.readAsBytes());
                          final url = await ref.getDownloadURL();
                          await FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId)
                              .update({
                            'payment': {
                              'type': 'slip',
                              'slipUrl': url,
                              'uploadedAt': FieldValue.serverTimestamp(),
                            },
                            'updatedAt': FieldValue.serverTimestamp(),
                          });
                        }

                        // 4) เคลียร์ตะกร้า + นำทาง
                        cartStore.clear();
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacementNamed(
                          context,
                          '/orderPreparing', 
                          arguments: {
                            'orderId': orderId,
                            'grandTotal': grandTotal
                          },
                        );
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('สั่งซื้อไม่สำเร็จ: $e')),
                        );
                      }
                    },
              child: const Text('ดำเนินการขั้นต่อไป'),
            ),
          ),
        ),
      ),
    );
  }

  // แถวข้อความสรุป (ใช้แค่ 2 อันนี้ให้จำง่าย ๆ)
  static Widget _row(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [Expanded(child: Text(l)), Text(r)]),
      );

  static Widget _rowBold(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(
              child:
                  Text(l, style: const TextStyle(fontWeight: FontWeight.w900))),
          Text(r, style: const TextStyle(fontWeight: FontWeight.w900)),
        ]),
      );
}
