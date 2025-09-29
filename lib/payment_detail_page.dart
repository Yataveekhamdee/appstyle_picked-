import 'package:flutter/material.dart';

/// ใช้ร่วมกับหน้าอื่น ๆ ในโปรเจกต์
class CheckoutArgs {
  final String title;
  final double price;
  final String image;
  final int qty;
  const CheckoutArgs({
    required this.title,
    required this.price,
    required this.image,
    this.qty = 1,
  });
}

class PaymentDetailPage extends StatelessWidget {
  const PaymentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as CheckoutArgs?;

    // ---- Mock / Fallback ----
    final title = args?.title ?? 'Cintage Retro Tee';
    final price = args?.price ?? 290;
    final qty   = args?.qty   ?? 1;

    // ปรับค่าพวกนี้ได้ตามจริง หรือดึงจาก backend
    const shippingMethod = 'Thailand-Post';
    const addressLine =
        'คุณ ญาตาวี 249 ม.2 ต.ดอนทราย อ.ปากท่อ จ.ราชบุรี 70235\nเบอร์โทร 08x-xxxx-xxx';
    const discount = 0.0;             // ส่วนลด
    const shippingFee = 0.0;          // ค่าส่ง
    const vatIncluded = true;         // ราคารวม VAT แล้ว
    final subTotal = price * qty;
    final total = subTotal - discount + shippingFee;

    // สร้าง URL QR (ตัวอย่าง) — เปลี่ยนเป็นของคุณได้
    final qrValue =
        'PAYMENT|title=$title|amount=${total.toStringAsFixed(2)}|qty=$qty';
    final qrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${Uri.encodeComponent(qrValue)}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2BA84A), // เขียวหัวตามภาพตัวอย่าง
        foregroundColor: Colors.white,
        title: const Text('รายละเอียดการชำระเงิน'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        children: [
          // สถานะการจัดส่ง + ที่อยู่
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RowIconTitle(
                  icon: Icons.local_shipping_outlined,
                  title: 'สถานะการจัดส่ง',
                  trailing: Text(
                    shippingMethod,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const Divider(height: 20),
                const _RowIconTitle(
                  icon: Icons.place_outlined,
                  title: 'ที่อยู่ในการจัดส่ง',
                ),
                const SizedBox(height: 6),
                Text(
                  addressLine,
                  style: const TextStyle(fontSize: 13.5, height: 1.5),
                ),
              ],
            ),
          ),

          // สรุปรายการ/ยอดรวม
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _RowIconTitle(
                  icon: Icons.receipt_long_outlined,
                  title: 'ยอดรวม (รายการ)',
                ),
                const SizedBox(height: 10),
                _KV('สินค้า', '$title x$qty'),
                _KV('ราคาสินค้า', '฿ ${subTotal.toStringAsFixed(0)}.-'),
                _KV('ยอดส่วนลด', discount == 0 ? '฿ 0' : '-฿ ${discount.toStringAsFixed(0)}',
                    valueColor: Colors.red),
                _KV('ค่าจัดส่ง', shippingFee == 0 ? 'ฟรี' : '฿ ${shippingFee.toStringAsFixed(0)}',
                    valueColor: shippingFee == 0 ? Colors.green : null),
                const SizedBox(height: 6),
                const Divider(height: 20),
                _KV('ยอดสั่งซื้อรวม ${vatIncluded ? 'VAT' : '่'}',
                    '฿ ${total.toStringAsFixed(0)}.-',
                    isBold: true),
              ],
            ),
          ),

          // ช่องทางการชำระเงิน (QR)
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _RowIconTitle(
                  icon: Icons.qr_code_2_outlined,
                  title: 'ช่องทางการชำระเงิน',
                ),
                const SizedBox(height: 4),
                const Text('สแกน QR CODE', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      qrUrl,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 180,
                        height: 180,
                        color: const Color(0xFFEFEFEF),
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined, size: 36),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'ยอดชำระ: ฿ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),

          // เวลาที่สั่งซื้อ
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _RowIconTitle(
                  icon: Icons.access_time_outlined,
                  title: 'เวลาที่สั่งซื้อ',
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDateTime(DateTime.now()),
                  style: const TextStyle(fontSize: 13.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),

      // ปุ่มดำเนินการต่อ (fixed bottom)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF707070), // เทาเข้มตามภาพ "ดำเนินการต่อ"
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // TODO: ยืนยันหลักฐาน / อัปโหลดสลิป / ไปหน้าสำเร็จ
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ดำเนินการต่อ')),
                );
              },
              child: const Text('ดำเนินการต่อ',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    // 14-02-2023 20:20 (สไตล์เดียวกับภาพ)
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d-$m-$y $h:$min';
  }
}

// ───────── Widgets ย่อย ─────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: child,
    );
  }
}

class _RowIconTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  const _RowIconTitle({
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 14.5)),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _KV extends StatelessWidget {
  final String keyText;
  final String valueText;
  final Color? valueColor;
  final bool isBold;
  const _KV(this.keyText, this.valueText,
      {this.valueColor, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isBold ? 15 : 13.5,
      fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
      color: valueColor ?? Colors.black,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(keyText, style: const TextStyle(fontSize: 13.5))),
          Text(valueText, style: style),
        ],
      ),
    );
  }
}
