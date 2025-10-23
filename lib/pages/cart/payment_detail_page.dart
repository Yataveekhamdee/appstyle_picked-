// lib/pages/checkout/payment_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/cart_store.dart';
import '../../services/firestore_service.dart';

class PaymentDetailPage extends StatefulWidget {
  const PaymentDetailPage({super.key});
  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  XFile? _slip;

  Future<String?> _ensureSignedIn() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u != null) return u.uid;
    Navigator.pushNamed(context, '/login', arguments: {
      'redirect': '/paymentDetail',
      'data': ModalRoute.of(context)?.settings.arguments,
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartStore>();

    // รับ args แบบสั้น
    final raw = ModalRoute.of(context)?.settings.arguments;
    final args =
        (raw is Map) ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    double _num(v) => (v is num) ? v.toDouble() : 0.0;

    final itemsTotal = _num(args['itemsTotal']);
    final shipping = _num(args['shippingFee']);
    final discount = _num(args['discount']);
    final grand = (args['grandTotal'] as num?)?.toDouble() ??
        (itemsTotal + shipping - discount);
    final method = (args['methodLabel'] as String?) ?? 'Mobile Banking';

    final addr =
        Map<String, dynamic>.from((args['address'] as Map?) ?? const {});
    final name = (addr['name'] ?? '').toString();
    final phone = (addr['phone'] ?? '').toString();
    final line1 = (addr['line1'] ?? '').toString();
    final district = (addr['district'] ?? '').toString();
    final province = (addr['province'] ?? '').toString();
    final zip = (addr['zip'] ?? '').toString();

    String _now() {
      final t = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(t.day)}/${two(t.month)}/${t.year}  ${two(t.hour)}:${two(t.minute)}';
    }

    // ปุ่มจะกดได้ต่อเมื่อเลือกสลิปแล้ว + มีของในตะกร้า
    final canSubmit = _slip != null && cart.items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดการชำระเงิน')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
        children: [
          // 1) ที่อยู่
          _card(ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(name.isEmpty ? 'ชื่อผู้รับ' : name),
            subtitle: Text('$line1\n$district  $province  $zip\n$phone'),
            trailing: const Chip(label: Text('จัดส่ง')),
          )),

          // 2) สรุปยอด
          _card(Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              _kv('ราคาสินค้า', '฿${itemsTotal.toStringAsFixed(0)}'),
              _kv('ส่วนลด',
                  discount == 0 ? '—' : '-฿${discount.toStringAsFixed(0)}'),
              _kv('ค่าจัดส่ง',
                  shipping == 0 ? 'ฟรี' : '฿${shipping.toStringAsFixed(0)}'),
              const Divider(),
              _kvBold('ยอดชำระรวม', '฿${grand.toStringAsFixed(0)}'),
            ]),
          )),

          // 3) QR โอนเงิน
          _card(Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('สแกนชำระเงิน (QR โอนเงิน)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child:
                      Image.asset('assets/images/qr/qr.jpg', fit: BoxFit.cover),
                ),
              ),
            ]),
          )),

          // 4) แนบสลิป
          _card(Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final x = await ImagePicker()
                      .pickImage(source: ImageSource.gallery, imageQuality: 85);
                  if (x != null) setState(() => _slip = x);
                },
                icon: const Icon(Icons.upload_file),
                label: Text(_slip == null ? 'เลือกสลิป' : 'เปลี่ยนสลิป'),
              ),
              const SizedBox(width: 12),
              if (_slip != null)
                Expanded(
                    child: Text(_slip!.name, overflow: TextOverflow.ellipsis)),
            ]),
          )),

          // ช่องทาง + เวลา (สรุปสั้น)
          _card(ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('ช่องทางการชำระเงิน'),
            subtitle: Text(method),
            trailing: Text('฿${grand.toStringAsFixed(2)}'),
          )),
          _card(ListTile(
              leading: const Icon(Icons.schedule), title: Text(_now()))),
        ],
      ),

      // ปุ่มยืนยัน
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: canSubmit
                  ? () async {
                      // กันเคสเผลอกดซ้ำ/ไม่มีสินค้า
                      if (cart.items.isEmpty) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('ตะกร้าสินค้าว่าง')));
                        }
                        return;
                      }

                      final uid = await _ensureSignedIn();
                      if (uid == null) return;

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('กำลังสร้างคำสั่งซื้อ...')));
                      }

                      try {
                        // 1) รายการสินค้าอย่างย่อ
                        final items = cart.items
                            .map((e) => {
                                  'productId': e.productId,
                                  'title': e.title,
                                  'image': e.image,
                                  'price': e.price,
                                  'qty': e.qty,
                                })
                            .toList();

                        // 2) สร้างออเดอร์ (ยังไม่ใส่ slipUrl)
                        final orderId = await FirestoreService.createOrder(
                          items: items,
                          address: {
                            'name': name,
                            'line1': line1,
                            'district': district,
                            'province': province,
                            'zip': zip,
                            'phone': phone
                          },
                          itemsTotal: itemsTotal,
                          shippingFee: shipping,
                          grandTotal: grand,
                          paymentMethod: method,
                          status: 'pending',
                          userId: uid,
                        );

                        // 3) อัปโหลดสลิป (มีแน่ เพราะ canSubmit)
                        final ts = DateTime.now().millisecondsSinceEpoch;
                        final ref = FirebaseStorage.instance
                            .ref()
                            .child('orders/$orderId/slip_$ts.jpg');
                        await ref.putData(await _slip!.readAsBytes(),
                            SettableMetadata(contentType: 'image/jpeg'));
                        final url = await ref.getDownloadURL();
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .doc(orderId)
                            .update({
                          'payment': {
                            'type': 'slip',
                            'slipUrl': url,
                            'uploadedAt': FieldValue.serverTimestamp()
                          },
                          'updatedAt': FieldValue.serverTimestamp(),
                        });

                        // 4) เคลียร์ตะกร้า + ไปหน้าถัดไป
                        cart.clear();
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(
                          context,
                          '/orderPreparing',
                          arguments: {'orderId': orderId, 'grandTotal': grand},
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('สั่งซื้อไม่สำเร็จ: $e')));
                        }
                      }
                    }
                  : null,
              child: const Text('ดำเนินการขั้นต่อไป'),
            ),
          ),
        ),
      ),
    );
  }

  /* ===== UI helpers แบบสั้น ===== */
  Widget _card(Widget child) => Card(child: child);

  Widget _kv(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [Expanded(child: Text(l)), Text(r)]),
      );

  Widget _kvBold(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(
              child:
                  Text(l, style: const TextStyle(fontWeight: FontWeight.w900))),
          Text(r, style: const TextStyle(fontWeight: FontWeight.w900)),
        ]),
      );
}
