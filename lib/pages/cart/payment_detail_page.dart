import 'package:flutter/material.dart';

class PaymentDetailPage extends StatelessWidget {
  const PaymentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ----- รับ arguments แบบปลอดภัย -----
    final raw = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> args =
        raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

    // ตัวเลขสำคัญ
    final double itemsTotal = (args['itemsTotal'] as num?)?.toDouble() ?? 0.0;
    final double shippingFee = (args['shippingFee'] as num?)?.toDouble() ?? 0.0;
    final double discount    = (args['discount'] as num?)?.toDouble() ?? 0.0;
    final double grandTotal  =
        (args['grandTotal'] as num?)?.toDouble() ??
        (itemsTotal + shippingFee - discount);

    // วิธีชำระเงิน: รองรับทั้งส่ง label และส่ง index 'payment'
    const labels = <String>[
      'เก็บเงินปลายทาง',
      'PromptPay',
      'บัตรเครดิต/บัตรเดบิต',
      'Online Banking',
      'TrueMoney Wallet',
      'PayPal',
    ];
    final int paymentIndex = (args['payment'] as int?) ?? 1;
    final String methodLabel =
        (args['methodLabel'] as String?) ??
        ((paymentIndex >= 0 && paymentIndex < labels.length)
            ? labels[paymentIndex]
            : 'PromptPay');

    // ที่อยู่: รองรับทั้ง Map และอ็อบเจ็กต์ (เช่น ShippingAddress)
    final dynamic addr = args['address'];
    String name     = 'คุณ ญาดา ชาติ';
    String line1    = '249 ม.2 ต.คอนสาร';
    String district = 'อ.ปากท่อ';
    String province = 'จ.ราชบุรี 70140';
    String phone    = 'เบอร์โทร 08x-xxxx-xxx';

    if (addr is Map) {
      name     = (addr['name'] ?? name).toString();
      line1    = (addr['line1'] ?? line1).toString();
      district = (addr['district'] ?? district).toString();
      province = (addr['province'] ?? province).toString();
      phone    = (addr['phone'] ?? phone).toString();
    } else if (addr != null) {
      // อ่าน field แบบ dynamic เพื่อไม่ต้อง import class
      try { name     = (addr as dynamic).name     ?? name;     } catch (_) {}
      try { line1    = (addr as dynamic).line1    ?? line1;    } catch (_) {}
      try { district = (addr as dynamic).district ?? district; } catch (_) {}
      try { province = (addr as dynamic).province ?? province; } catch (_) {}
      try { phone    = (addr as dynamic).phone    ?? phone;    } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF22A64B),
        foregroundColor: Colors.white,
        title: const Text('รายละเอียดการชำระเงิน'),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
        children: [
          // ----- กล่องที่อยู่ -----
          _card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.place_outlined, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(line1),
                      Text('$district  $province'),
                      Text(phone),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F6EE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Thailand-Post',
                    style: TextStyle(color: Color(0xFF22A64B), fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          // ----- กล่องสรุปยอด -----
          _card(
            child: Column(
              children: [
                _row('ราคาสินค้า', '฿${itemsTotal.toStringAsFixed(0)}'),
                _row('ยอดส่วนลด', '-฿${discount.toStringAsFixed(0)}'),
                _row('ค่าจัดส่ง', shippingFee == 0 ? 'ฟรี' : '฿${shippingFee.toStringAsFixed(0)}'),
                const Divider(),
                _rowBold('ยอดชำระรวม VAT', '฿${grandTotal.toStringAsFixed(0)}'),
              ],
            ),
          ),

          // ----- ช่องทางการชำระเงิน (เปลี่ยนตามวิธี) -----
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ช่องทางการชำระเงิน ($methodLabel)',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                _paymentWidget(methodLabel),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('ยอดชำระ: ฿${grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          // เวลา
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('เวลาที่สั่งซื้อ', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(_nowString()),
              ],
            ),
          ),
        ],
      ),

      // ----- ปุ่มดำเนินการต่อ -----
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22A64B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/orderPreparing',
                  arguments: {'grandTotal': grandTotal},
                );
              },
              child: const Text('ดำเนินการขั้นต่อไป',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── helpers ─────────

  static Widget _card({required Widget child}) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEAEAEA)),
        ),
        child: child,
      );

  static Widget _row(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(child: Text(l)),
          Text(r),
        ]),
      );

  static Widget _rowBold(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(child: Text(l, style: const TextStyle(fontWeight: FontWeight.w900))),
          Text(r, style: const TextStyle(fontWeight: FontWeight.w900)),
        ]),
      );

  // เปลี่ยน UI ตามวิธีชำระเงิน
  Widget _paymentWidget(String method) {
    final lower = method.toLowerCase();

    if (lower.contains('prompt')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('สแกน QR CODE เพื่อชำระเงิน (PromptPay)'),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  // ใส่ไฟล์รูป QR ของคุณไว้ที่ path นี้
                  'assets/images/payments/qr_promptpay.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.qr_code_2, size: 120, color: Colors.black26),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (lower.contains('เก็บเงินปลายทาง')) {
      return Row(
        children: const [
          Icon(Icons.payments_outlined),
          SizedBox(width: 8),
          Expanded(child: Text('ชำระเงินปลายทางกับพนักงานจัดส่ง')),
        ],
      );
    }

    if (lower.contains('เครดิต') || lower.contains('เดบิต')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('บัตรเครดิต/บัตรเดบิต'),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/payments/card_sample.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.credit_card, size: 72, color: Colors.black26),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // default
    return Row(
      children: [
        const Icon(Icons.account_balance_wallet_outlined),
        const SizedBox(width: 8),
        Expanded(child: Text('ชำระด้วย $method')),
      ],
    );
  }

  String _nowString() {
    final dt = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}-${two(dt.month)}-${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
