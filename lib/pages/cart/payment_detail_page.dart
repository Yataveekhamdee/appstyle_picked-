import 'package:flutter/material.dart'; 
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_storage/firebase_storage.dart'; 
import 'package:image_picker/image_picker.dart'; 

import '../../providers/cart_store.dart'; 
import '../../services/firestore_service.dart';

class PaymentDetailPage extends StatefulWidget {
  // หน้า "รายละเอียดการชำระเงิน" ก่อนยืนยันออเดอร์จริง
  const PaymentDetailPage({super.key});
  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  XFile? _slip;
  // เก็บรูปสลิป (หลักฐานโอนเงิน). ถ้ายังไม่เลือกสลิป = null

  Future<String?> _ensureSignedIn() async {
    // ฟังก์ชันเช็คว่าล็อกอินรึยัง
    final u = FirebaseAuth.instance.currentUser; // ดู user ปัจจุบัน
    if (u != null) return u.uid; // ถ้าล็อกอินแล้ว -> ส่ง uid กลับไป
    // ถ้ายังไม่ล็อกอิน -> ส่งไปหน้า login พร้อมบอกว่าจะกลับมาหน้านี้
    Navigator.pushNamed(context, '/login', arguments: {
      'redirect': '/paymentDetail',
      'data': ModalRoute.of(context)?.settings.arguments,
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartStore>();
    // cart = ดูสถานะตะกร้าจาก provider (มีอะไรอยู่ในตะกร้า, ยอดรวม ฯลฯ)

    // ดึงข้อมูลที่ส่งมาจากหน้า Checkout (ที่กด "ตกลง" มา)
    final raw = ModalRoute.of(context)?.settings.arguments;
    final args =
        (raw is Map) ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

    double _num(v) => (v is num) ? v.toDouble() : 0.0;
    // ฟังก์ชันเล็ก ๆ แปลงเป็น double แบบปลอดภัย

    final itemsTotal = _num(args['itemsTotal']); // ราคารวมสินค้า
    final shipping = _num(args['shippingFee']); // ค่าส่ง
    final discount = _num(args['discount']); // ส่วนลด
    final grand = (args['grandTotal'] as num?)?.toDouble() ??
        (itemsTotal + shipping - discount); // ยอดสุดท้ายที่ต้องจ่าย
    final method = (args['methodLabel'] as String?) ?? 'Mobile Banking';
    // ช่องทางชำระเงิน เช่น "Mobile Banking"

    // ข้อมูลที่อยู่จัดส่ง
    final addr =
        Map<String, dynamic>.from((args['address'] as Map?) ?? const {});
    final name = (addr['name'] ?? '').toString();
    final phone = (addr['phone'] ?? '').toString();
    final line1 = (addr['line1'] ?? '').toString();
    final district = (addr['district'] ?? '').toString();
    final province = (addr['province'] ?? '').toString();
    final zip = (addr['zip'] ?? '').toString();

    // ฟังก์ชันเอาวันที่-เวลา ณ ตอนนี้ ไปแสดงใน UI สวยๆ
    String _now() {
      final t = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(t.day)}/${two(t.month)}/${t.year}  ${two(t.hour)}:${two(t.minute)}';
    }

    // ปุ่มยืนยันจะกดได้ ก็ต่อเมื่อ
    // - มีสลิป (_slip != null)
    // - ตะกร้าไม่ว่าง
    final canSubmit = _slip != null && cart.items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดการชำระเงิน')),
      // หัวหน้าจอ

      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
        // ใช้ ListView ให้เลื่อนลงได้ + เผื่อพื้นที่ปุ่มล่าง 120px

        children: [
          // -------- [1] การจัดส่ง / ที่อยู่ผู้รับ --------
          _card(
            ListTile(
              leading: const Icon(Icons.place_outlined), // ไอคอนตำแหน่ง
              title: Text(name.isEmpty ? 'ชื่อผู้รับ' : name), // ชื่อผู้รับ
              subtitle: Text(
                '$line1\n$district  $province  $zip\n$phone',
                // ที่อยู่เต็ม + เบอร์โทร
              ),
              trailing: const Chip(label: Text('จัดส่ง')),
              // Chip เล็ก ๆ บอกว่านี่คือที่จัดส่ง
            ),
          ),

          //   สรุปยอดเงิน
          _card(
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _kv('ราคาสินค้า', '฿${itemsTotal.toStringAsFixed(0)}'),
                  _kv('ส่วนลด',
                      discount == 0 ? '—' : '-฿${discount.toStringAsFixed(0)}'),
                  _kv(
                      'ค่าจัดส่ง',
                      shipping == 0
                          ? 'ฟรี'
                          : '฿${shipping.toStringAsFixed(0)}'),
                  const Divider(),
                  _kvBold('ยอดชำระรวม', '฿${grand.toStringAsFixed(0)}'),
                  // โชว์ยอดสุดท้ายแบบตัวหนา
                ],
              ),
            ),
          ),

          // -------- [3] QR ให้ลูกค้าสแกนโอน --------
          _card(
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('สแกนชำระเงิน (QR โอนเงิน)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // มุมภาพโค้งสวย

                    child: AspectRatio(
                      aspectRatio: 1,
                      // ทำให้เป็นรูปสี่เหลี่ยมจตุรัส

                      child: Image.asset(
                        'assets/images/qr/qr.jpg',
                        fit: BoxFit.cover,
                      ),
                      // รูป QR โอนเงิน (ภาพใน assets)
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -------- [4] ปุ่มอัปโหลดสลิปโอนเงิน --------
          _card(
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    // ปุ่มเลือกไฟล์รูปจากเครื่อง
                    onPressed: () async {
                      final x = await ImagePicker().pickImage(
                        source: ImageSource.gallery, // เปิดแกลเลอรี่
                        imageQuality: 85, // ลดขนาดภาพหน่อย
                      );
                      if (x != null) setState(() => _slip = x);
                      // ถ้าเลือกแล้ว -> เก็บภาพไว้ใน _slip
                    },
                    icon: const Icon(Icons.upload_file),
                    label: Text(_slip == null ? 'เลือกสลิป' : 'เปลี่ยนสลิป'),
                  ),
                  const SizedBox(width: 12),
                  if (_slip != null)
                    Expanded(
                      child: Text(
                        _slip!.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // โชว์ชื่อไฟล์สลิปที่เราเลือก
                    ),
                ],
              ),
            ),
          ),

          // -------- [5] วิธีจ่ายเงิน + ราคา --------
          _card(
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              // ไอคอนกระเป๋าเงิน

              title: const Text('ช่องทางการชำระเงิน'),
              subtitle: Text(method),
              // เช่น "Mobile Banking"

              trailing: Text('฿${grand.toStringAsFixed(2)}'),
              // โชว์ยอดอีกครั้ง
            ),
          ),

          // -------- [6] เวลา (timestamp) --------
          _card(
            ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(_now()),
              // เวลาปัจจุบัน เช่น "25/10/2025  14:32"
            ),
          ),
        ],
      ),

      // -------- ปุ่มยืนยันคำสั่งซื้อด้านล่าง --------
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: canSubmit
                  ? () async {
                      // ถ้ายังไม่ได้แนบสลิป หรือ ตะกร้าว่าง -> ปุ่มถูกปิด (null)

                      // 1) กันเคส: ตะกร้าดันว่าง
                      if (cart.items.isEmpty) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ตะกร้าสินค้าว่าง')),
                          );
                        }
                        return;
                      }

                      // 2) ถ้ายังไม่ล็อกอิน -> พาไปล็อกอินก่อน
                      final uid = await _ensureSignedIn();
                      if (uid == null) return;

                      // แจ้งผู้ใช้ว่ากำลังประมวลผล
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('กำลังสร้างคำสั่งซื้อ...')),
                        );
                      }

                      try {
                        // 3) สร้างรายการสินค้า (list of map) เพื่อบันทึกลงออเดอร์
                        final items = cart.items
                            .map((e) => {
                                  'productId': e.productId,
                                  'title': e.title,
                                  'image': e.image,
                                  'price': e.price,
                                  'qty': e.qty,
                                })
                            .toList();

                        // 4) สร้างออเดอร์ใน Firestore (ยังไม่มี slipUrl ตอนนี้)
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
                          shippingFee: shipping,
                          grandTotal: grand,
                          paymentMethod: method,
                          status: 'pending', // สถานะเริ่มต้น: รอร้านตรวจสลิป
                          userId: uid,
                        );

                        // 5) อัปโหลดไฟล์สลิปไป Firebase Storage
                        final ts = DateTime.now().millisecondsSinceEpoch;
                        final ref = FirebaseStorage.instance
                            .ref()
                            .child('orders/$orderId/slip_$ts.jpg');
                        // path เก็บ: orders/<orderId>/slip_TIMESTAMP.jpg

                        await ref.putData(
                          await _slip!.readAsBytes(),
                          SettableMetadata(contentType: 'image/jpeg'),
                        );
                        // อัปโหลดรูป

                        final url = await ref.getDownloadURL();
                        // ดึงลิงก์รูปสลิปที่อัปโหลดแล้ว

                        // 6) อัปเดตออเดอร์ให้มีข้อมูลสลิป
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

                        // 7) เคลียร์ตะกร้า + ไปหน้า "กำลังเตรียมจัดส่ง"
                        cart.clear(); // ล้างตะกร้า
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(
                          context,
                          '/orderPreparing',
                          arguments: {
                            'orderId': orderId,
                            'grandTotal': grand,
                          },
                        );
                      } catch (e) {
                        // ถ้า error เช่น เน็ตพัง/อัปโหลด fail ฯลฯ -> แจ้งเตือน
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('สั่งซื้อไม่สำเร็จ: $e')),
                          );
                        }
                      }
                    }
                  : null,
              // ถ้า canSubmit เป็น false -> ปุ่มปิด (กดไม่ได้)
              child: const Text('ดำเนินการขั้นต่อไป'),
            ),
          ),
        ),
      ),
    );
  }

  /* ===== UI helpers แบบสั้น ===== */
  Widget _card(Widget child) => Card(child: child);
  // _card(...) = ห่อ widget ให้เป็น Card สวย ๆ

  Widget _kv(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(child: Text(l)), // ข้อความซ้าย เช่น "ราคาสินค้า"
          Text(r), // ค่าขวา เช่น "฿500"
        ]),
      );

  Widget _kvBold(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(
            child: Text(
              l,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            r,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ]),
      );
}


