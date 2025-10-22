import 'package:flutter/material.dart';
import '../../providers/cart_store.dart';


class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _form = GlobalKey<FormState>();
  String name = 'ญาดา พ่วงเกิด',
      phone = '098-002-8979',
      line1 = '123 ม.5 ต.คอนสาร',
      district = 'อ.ปากท่อ',
      province = 'จ.ราชบุรี',
      zip = '70140';

  int pay = 0; // 0=บัตร, 1=Mobile

  double get itemsTotal => cartStore.total;
  double get ship => 0;
  double get grand => itemsTotal + ship;
  String get method => pay == 0 ? 'บัตรเครดิต/เดบิต' : 'Mobile Banking';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: cartStore,
      builder: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('ยืนยันคำสั่งซื้อ')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ที่อยู่ (แก้บนหน้าเดียว)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: _form,
                  child: Column(children: [
                    _tf('ชื่อ-นามสกุล',
                        initial: name,
                        onSaved: (v) => name = v!,
                        validator: _req),
                    _tf('เบอร์โทร',
                        initial: phone,
                        keyboard: TextInputType.phone,
                        onSaved: (v) => phone = v!,
                        validator: (v) => _req(v) ?? _phone(v)),
                    _tf('ที่อยู่',
                        initial: line1,
                        onSaved: (v) => line1 = v!,
                        validator: _req),
                    Row(children: [
                      Expanded(
                          child: _tf('อำเภอ/เขต',
                              initial: district,
                              onSaved: (v) => district = v!,
                              validator: _req)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _tf('จังหวัด',
                              initial: province,
                              onSaved: (v) => province = v!,
                              validator: _req)),
                    ]),
                    _tf('รหัสไปรษณีย์',
                        initial: zip,
                        keyboard: TextInputType.number,
                        onSaved: (v) => zip = v!,
                        validator: (v) => _req(v) ?? _zip(v)),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // รายการสินค้า
            Card(
              child: Column(children: [
                const ListTile(
                    title: Text('สั่งซื้อสินค้า',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('จัดส่งฟรี')),
                const Divider(height: 0),
                ...cartStore.items.map((e) => ListTile(
                      dense: true,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _img(e.image, 56, 56),
                      ),
                      title: Text(e.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text('x${e.qty}'),
                      trailing: Text('฿${(e.price * e.qty).toStringAsFixed(0)}',
                          style: TextStyle(
                              color: cs.error, fontWeight: FontWeight.w900)),
                    )),
              ]),
            ),
            const SizedBox(height: 10),

            // วิธีชำระเงิน (สั้นๆ)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('การชำระเงิน',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const Spacer(),
                  DropdownButton<int>(
                    value: pay,
                    items: const [
                      DropdownMenuItem(
                          value: 0, child: Text('บัตรเครดิต/เดบิต')),
                      DropdownMenuItem(value: 1, child: Text('Mobile Banking')),
                    ],
                    onChanged: (v) => setState(() => pay = v!),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 10),

            // สรุปยอด
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  _row('ราคาสินค้า', '฿${itemsTotal.toStringAsFixed(0)}'),
                  _row('ค่าจัดส่ง', '฿${ship.toStringAsFixed(0)}'),
                  const Divider(),
                  _rowBold('ยอดรวม', '฿${grand.toStringAsFixed(0)}'),
                ]),
              ),
            ),
          ]),
        ),

        // แถบรวมยอด + ปุ่มตกลง
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(children: [
              const Expanded(
                  child: Text('ยอดชำระ', style: TextStyle(fontSize: 12))),
              Text('฿${grand.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: cartStore.items.isEmpty
                    ? null
                    : () {
                        if (!(_form.currentState?.validate() ?? false)) return;
                        _form.currentState?.save();
                        Navigator.pushNamed(context, '/paymentDetail',
                            arguments: {
                              'itemsTotal': itemsTotal,
                              'shippingFee': ship,
                              'discount': 0.0,
                              'grandTotal': grand,
                              'methodLabel': method,
                              'address': {
                                'name': name,
                                'phone': phone,
                                'line1': line1,
                                'district': district,
                                'province': province,
                                'zip': zip,
                              },
                            });
                      },
                child: const Text('ตกลง'),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // helpers (เวอร์ชันสั้น)
  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'กรุณากรอก' : null;
  String? _phone(String? v) {
    final s = (v ?? '').replaceAll(RegExp(r'\D'), '');
    return s.length < 9 ? 'เบอร์ไม่ถูกต้อง' : null;
  }

  String? _zip(String? v) {
    final s = (v ?? '').trim();
    return s.length != 5 || int.tryParse(s) == null ? 'รหัส 5 หลัก' : null;
  }

  Widget _tf(String label,
      {String? initial,
      TextInputType? keyboard,
      String? Function(String?)? validator,
      required void Function(String?) onSaved}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        initialValue: initial,
        keyboardType: keyboard,
        validator: validator,
        onSaved: onSaved,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _row(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [Expanded(child: Text(l)), Text(r)]),
      );

  Widget _rowBold(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(
              child:
                  Text(l, style: const TextStyle(fontWeight: FontWeight.w900))),
          Text(r, style: const TextStyle(fontWeight: FontWeight.w900)),
        ]),
      );

  Widget _img(String path, double w, double h) {
    final fb = const ColoredBox(color: Color(0xFFEFEFEF));
    if (path.startsWith('http')) {
      return Image.network(path,
          width: w,
          height: h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              SizedBox(width: w, height: h, child: fb));
    }
    return Image.asset(path,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => SizedBox(width: w, height: h, child: fb));
  }
}
