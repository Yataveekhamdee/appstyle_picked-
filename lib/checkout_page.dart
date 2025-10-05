import 'package:flutter/material.dart';
import 'cart_store.dart';
import 'address_form_page.dart'; // ใช้ ShippingAddress + หน้าแก้ที่อยู่

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // ───────── ตัวเลือกในหน้า ─────────
  String shipping = 'express'; // express | standard
  bool etaProtect = false;     // การรับประกันจัดส่งตามเวลา
  int payment = 1;             // index วิธีชำระเงิน (ตั้งต้นเป็น PromptPay สวย ๆ)
  bool couponApplied = false;  // เปิด/ปิดคูปอง
  double couponDiscount = 50;  // ✅ คูปองลด 50 บาท

  // ───────── วิธีชำระเงินทั้งหมด ─────────
  final _payOptions = <_PayOpt>[
    _PayOpt('เก็บเงินปลายทาง', Icons.payments_outlined),
    _PayOpt('PromptPay', Icons.qr_code_2),
    _PayOpt('บัตรเครดิต/บัตรเดบิต', Icons.credit_card),
    _PayOpt('Online Banking', Icons.account_balance),
    _PayOpt('TrueMoney Wallet', Icons.account_balance_wallet_outlined),
    _PayOpt('PayPal', Icons.account_balance_wallet),
  ];

  String get _methodLabel => _payOptions[payment].label;

  // ───────── ที่อยู่เริ่มต้น ─────────
  ShippingAddress _addr = const ShippingAddress(
    name: 'ญาดา  ชาติ',
    phone: '098-002-8979',
    line1: '249 ม.2 ต.คอนสาร',
    district: 'อ.ปากท่อ',
    province: 'จ.ราชบุรี',
    zip: '70140',
  );

  // ───────── คำนวณยอด ─────────
  double get itemsTotal => cartStore.total;
  double get shippingFee => 0; // จัดส่งฟรี
  double get discount => couponApplied ? couponDiscount.clamp(0, itemsTotal) : 0;
  double get grandTotal => (itemsTotal + shippingFee - discount).clamp(0, 999999);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text('ยืนยันคำสั่งซื้อ', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),

      body: AnimatedBuilder(
        animation: cartStore,
        builder: (_, __) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusBar(),
                const SizedBox(height: 10),

                // ───────── ที่อยู่ ─────────
                _section(
                  child: ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(_addr.name),
                    subtitle: Text(
                      '${_addr.line1}\n'
                      '${_addr.district} ${_addr.province} ${_addr.zip}  •  ${_addr.phone}',
                      style: const TextStyle(height: 1.2),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    onTap: () async {
                      final res = await Navigator.pushNamed(
                        context,
                        '/address',
                        arguments: _addr,
                      );
                      if (res is ShippingAddress) {
                        setState(() => _addr = res);
                      }
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // ───────── รายการสินค้า ─────────
                _section(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFEFEFEF))),
                        ),
                        child: Row(
                          children: [
                            const Text('สั่งซื้อสินค้า', style: TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1E0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('เพิ่มสินค้าที่คูปองสูงสุดพิเศษ!',
                                  style: TextStyle(color: Colors.orange, fontSize: 11)),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      ...cartStore.items.map((e) => _itemRow(e)).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                _shippingSection(),
                const SizedBox(height: 10),

                _couponSection(),
                const SizedBox(height: 10),

                _paymentSection(), // มีพรีวิวเปลี่ยนตามตัวเลือก
                const SizedBox(height: 10),

                _summarySection(),
              ],
            ),
          );
        },
      ),

      // ───────── แถบรวมยอด + ปุ่มตกลง ─────────
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, -2))],
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text('ยอดชำระ:', style: TextStyle(fontSize: 12, color: Colors.black54)),
              ),
              Text('฿${grandTotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: cartStore.items.isEmpty
                    ? null
                    : () {
                        // ส่งเป็น Map ปลอดภัย + ส่ง methodLabel ไปด้วย
                        Navigator.pushNamed(
                          context,
                          '/paymentDetail',
                          arguments: {
                            'itemsTotal': itemsTotal,
                            'shippingFee': shippingFee,
                            'discount': discount,
                            'grandTotal': grandTotal,
                            'methodLabel': _methodLabel,
                            'address': {
                              'name': _addr.name,
                              'phone': _addr.phone,
                              'line1': _addr.line1,
                              'district': _addr.district,
                              'province': _addr.province,
                              'zip': _addr.zip,
                            },
                          },
                        );
                      },
                child: const Text('ตกลง'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────── Widgets ย่อย ─────────

  Widget _statusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD3E9CF)),
      ),
      child: Row(
        children: const [
          Icon(Icons.check_circle, color: Color(0xFF3CB371), size: 18),
          SizedBox(width: 6),
          Expanded(child: Text('ส่งฟรี', style: TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }

  Widget _itemRow(CartItem it) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEFEFEF))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              it.image,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 64,
                height: 64,
                child: ColoredBox(color: Color(0xFFEFEFEF)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('฿${it.price.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _qtyBox(
            value: it.qty,
            onDec: () => setState(() => cartStore.dec(it)),
            onInc: () => setState(() => cartStore.inc(it)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() => cartStore.remove(it)),
          ),
        ],
      ),
    );
  }

  Widget _qtyBox({required int value, required VoidCallback onDec, required VoidCallback onInc}) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(Icons.remove, onDec),
          SizedBox(
            width: 34,
            child: Center(
              child: Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          _qtyBtn(Icons.add, onInc),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData i, VoidCallback onTap) =>
      InkWell(onTap: onTap, child: SizedBox(width: 34, height: 36, child: Icon(i, size: 16)));

  Widget _shippingSection() {
    return _section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text('วิธีการจัดส่งสินค้า', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _shippingCard(
                  title: 'การจัดส่งแบบด่วน',
                  subtitle: 'จัดส่งฟรี',
                  selected: shipping == 'express',
                  onTap: () => setState(() => shipping = 'express'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _shippingCard(
                  title: 'การจัดส่งแบบมาตรฐาน',
                  subtitle: 'จัดส่งฟรี',
                  selected: shipping == 'standard',
                  onTap: () => setState(() => shipping = 'standard'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            value: etaProtect,
            onChanged: (v) => setState(() => etaProtect = v),
            title: const Text('การรับประกันการจัดส่งตามเวลาที่กำหนด'),
            subtitle: const Text('10 คะแนนจะคืนให้หากจัดส่งล่าช้า'),
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ],
      ),
    );
  }

  Widget _shippingCard({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.black : const Color(0xFFE0E0E0), width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7E8),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('ฟรี', style: TextStyle(color: Colors.green, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _couponSection() {
    return _section(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Row(
          children: [
            const Icon(Icons.local_offer_outlined, color: Colors.black87),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                couponApplied
                    ? 'คูปอง 1 ใบที่ใช้แล้ว รวมประหยัด ฿${discount.toStringAsFixed(0)}!'
                    : 'มีคูปองให้เลือกใช้',
                style: TextStyle(
                  color: couponApplied ? Colors.green.shade700 : Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => couponApplied = !couponApplied),
              child: Text(couponApplied ? 'ยกเลิก' : 'ใช้คูปอง'),
            ),
          ],
        ),
      ),
    );
  }

  // พรีวิววิธีชำระเงินแบบเปลี่ยนตามตัวเลือก
  Widget _paymentSection() {
    return _section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Text('การชำระเงิน', style: TextStyle(fontWeight: FontWeight.w800)),
          ),

          // รายการตัวเลือก
          ...List.generate(_payOptions.length, (i) {
            final o = _payOptions[i];
            return RadioListTile<int>(
              value: i,
              groupValue: payment,
              onChanged: (v) => setState(() => payment = v!),
              title: Text(o.label),
              secondary: Icon(o.icon),
              dense: true,
            );
          }),

          const SizedBox(height: 8),
          const Divider(height: 12),

          // พรีวิวด้านล่าง (เปลี่ยนตาม _methodLabel)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _paymentPreviewWidget(_methodLabel, key: ValueKey(_methodLabel)),
          ),
        ],
      ),
    );
  }

  Widget _paymentPreviewWidget(String method, {Key? key}) {
    final lower = method.toLowerCase();

    if (lower.contains('prompt')) {
      return Container(
        key: key,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('สแกน QR CODE เพื่อชำระเงิน (PromptPay)',
                style: TextStyle(fontWeight: FontWeight.w700)),
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
                    'assets/images/payments/qr_promptpay.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.qr_code_2, size: 120, color: Colors.black26)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (lower.contains('เก็บเงินปลายทาง')) {
      return ListTile(
        key: key,
        leading: const Icon(Icons.payments_outlined),
        title: const Text('ชำระเงินปลายทางกับพนักงานจัดส่ง'),
        subtitle: const Text('รองรับเงินสดเมื่อรับสินค้า'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      );
    }

    if (lower.contains('เครดิต') || lower.contains('เดบิต')) {
      return Container(
        key: key,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('บัตรเครดิต/บัตรเดบิต', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/payments/card_sample.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.credit_card, size: 72, color: Colors.black26)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('จะไปกรอกข้อมูลบัตรในขั้นตอนถัดไปอย่างปลอดภัย'),
          ],
        ),
      );
    }

    return ListTile(
      key: key,
      leading: const Icon(Icons.account_balance_wallet_outlined),
      title: Text('ชำระด้วย $method'),
      subtitle: const Text('จะดำเนินการในขั้นตอนถัดไป'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _summarySection() {
    return _section(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          children: [
            _row('ราคาสินค้า: ${cartStore.items.length} รายการ', '฿${itemsTotal.toStringAsFixed(0)}'),
            _row('ค่าจัดส่ง:', shippingFee == 0 ? '฿0  (จัดส่งฟรี)' : '฿${shippingFee.toStringAsFixed(0)}'),
            _row('คูปอง:', discount == 0 ? '—' : '-฿${discount.toStringAsFixed(0)}', red: true),
            const Divider(height: 16),
            _rowBold('ยอดรวมสุดท้าย', '฿${grandTotal.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String r, {bool red = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(l)),
            Text(
              r,
              style: TextStyle(
                color: red ? Colors.red : Colors.black,
                fontWeight: red ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      );

  Widget _rowBold(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(l, style: const TextStyle(fontWeight: FontWeight.w900))),
            Text(r, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      );

  Widget _section({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: child,
    );
  }
}

class _PayOpt {
  final String label;
  final IconData icon;
  _PayOpt(this.label, this.icon);
}
