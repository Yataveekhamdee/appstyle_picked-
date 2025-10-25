import 'package:flutter/material.dart'; // ใช้สร้าง UI ของหน้า
import '../../providers/cart_store.dart'; // ดึงข้อมูลตะกร้ามาใช้

class CheckoutPage extends StatefulWidget {
  // หน้า Checkout มีการเปลี่ยนค่าได้
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() =>
      _CheckoutPageState(); // ใช้ State ในการเก็บข้อมูลหน้า
}

class _CheckoutPageState extends State<CheckoutPage> {
  final form = GlobalKey<FormState>(); // ตัวช่วยตรวจช่องกรอก (validate / save)

  // ข้อมูลที่อยู่ (ค่าเริ่มต้น)
  String name = 'ญาดา พ่วงเกิด',
      phone = '098-002-8979',
      line1 = '123 ม.5 ต.คอนสาร',
      district = 'อ.ปากท่อ',
      province = 'จ.ราชบุรี',
      zip = '70140';

  // รวมราคา
  double get itemsTotal => cartStore.total; // ราคารวมสินค้า
  double get shipping => 0; // ค่าส่ง (ฟรี)
  double get grand => itemsTotal + shipping; // ยอดสุดท้าย
  String get method => 'Mobile Banking'; // วิธีจ่ายเงิน

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // อัปเดตจออัตโนมัติเมื่อ cart เปลี่ยน
      animation: cartStore,
      builder: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('ยืนยันคำสั่งซื้อ')), // แถบหัวหน้า

        body: ListView(
          // เนื้อหาหลัก เลื่อนขึ้นลงได้
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 120), // เว้นขอบ
          children: [
            // --- ฟอร์มกรอกที่อยู่ ---
            Card(
              // กล่องแสดงข้อมูล
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Form(
                  // กล่องรวมช่องกรอก
                  key: form,
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

            // --- รายการสินค้า ---
            Card(
              child: Column(children: [
                const ListTile(
                    title: Text('สั่งซื้อสินค้า',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('จัดส่งฟรี')),
                const Divider(height: 0),
                ...cartStore.items.map((e) => ListTile(
                      leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _img(e.image, 56, 56)), // รูปสินค้า
                      title: Text(e.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis), // ชื่อสินค้า
                      subtitle: Text('x${e.qty}'), // จำนวน
                      trailing: Text(
                          '฿${(e.price * e.qty).toStringAsFixed(0)}', // ราคาต่อชิ้นรวม
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w900)),
                    )),
              ]),
            ),
            const SizedBox(height: 10),

            // สรุปยอด
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  _row('ราคาสินค้า', '฿${itemsTotal.toStringAsFixed(0)}'),
                  _row('ค่าจัดส่ง', '฿${shipping.toStringAsFixed(0)}'),
                  const Divider(),
                  _rowBold('ยอดรวม', '฿${grand.toStringAsFixed(0)}'),
                ]),
              ),
            ),
          ],
        ),

        // ปุ่มชำระเงินด้านล่าง 
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(children: [
              const Text('ยอดชำระ'),
              const Spacer(),
              Text('฿${grand.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: cartStore.items.isEmpty
                    ? null
                    : _goPay, // ถ้าไม่มีของ ปุ่มกดไม่ได้
                child: const Text('ตกลง'),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'กรุณากรอก' : null; // ห้ามว่าง
  String? _phone(String? v) {
    final s =
        (v ?? '').replaceAll(RegExp(r'\D'), ''); // ลบทุกอย่างที่ไม่ใช่ตัวเลข
    return s.length < 9 ? 'เบอร์ไม่ถูกต้อง' : null; // ถ้าเบอร์สั้น = ผิด
  }

  String? _zip(String? v) {
    final s = (v ?? '').trim();
    return s.length != 5 || int.tryParse(s) == null
        ? 'รหัส 5 หลัก'
        : null; // ต้องเป็นเลข 5 ตัว
  }

  // ---------- ช่องกรอก (TextField) ----------
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

  
  Widget _row(String l, String r) =>
      Row(children: [Expanded(child: Text(l)), Text(r)]);
  Widget _rowBold(String l, String r) => Row(children: [
        Expanded(
            child:
                Text(l, style: const TextStyle(fontWeight: FontWeight.w900))),
        Text(r, style: const TextStyle(fontWeight: FontWeight.w900))
      ]);

  
  Widget _img(String path, double w, double h) => path.startsWith('http')
      ? Image.network(path, width: w, height: h)
      : Image.asset(path, width: w, height: h);


  void _goPay() {
    if (!(form.currentState?.validate() ?? false))
      return; // ถ้าฟอร์มไม่ผ่าน หยุด
    form.currentState?.save(); // เก็บค่าที่กรอก
    Navigator.pushNamed(context, '/paymentDetail', arguments: {
      'itemsTotal': itemsTotal,
      'shippingFee': shipping,
      'discount': 0.0,
      'grandTotal': grand,
      'methodLabel': method,
      'address': {
        'name': name,
        'phone': phone,
        'line1': line1,
        'district': district,
        'province': province,
        'zip': zip
      },
    });
  }
}
