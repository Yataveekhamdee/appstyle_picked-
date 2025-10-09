import 'package:flutter/material.dart';

/// โมเดลที่อยู่ (ใช้ส่งค่ากลับไปหน้า Checkout)
class ShippingAddress {
  final String name;
  final String phone;
  final String line1;     // บ้านเลขที่/หมู่/ถนน/ตำบล
  final String district;  // อำเภอ/เขต
  final String province;  // จังหวัด
  final String zip;       // รหัสไปรษณีย์

  const ShippingAddress({
    required this.name,
    required this.phone,
    required this.line1,
    required this.district,
    required this.province,
    required this.zip,
  });

  ShippingAddress copyWith({
    String? name,
    String? phone,
    String? line1,
    String? district,
    String? province,
    String? zip,
  }) {
    return ShippingAddress(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      line1: line1 ?? this.line1,
      district: district ?? this.district,
      province: province ?? this.province,
      zip: zip ?? this.zip,
    );
  }
}

class AddressFormPage extends StatefulWidget {
  const AddressFormPage({super.key});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _line1 = TextEditingController();
  final _district = TextEditingController();
  final _province = TextEditingController();
  final _zip = TextEditingController();

  @override
  void didChangeDependencies() {
    // รับค่าเริ่มต้นจาก arguments (ถ้ามี)
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg is ShippingAddress) {
      _name.text = arg.name;
      _phone.text = arg.phone;
      _line1.text = arg.line1;
      _district.text = arg.district;
      _province.text = arg.province;
      _zip.text = arg.zip;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _line1.dispose();
    _district.dispose();
    _province.dispose();
    _zip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขที่อยู่จัดส่ง'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 100),
            children: [
              _field('ชื่อ-สกุล', _name, TextInputType.name),
              _field('เบอร์โทร', _phone, TextInputType.phone,
                  validator: _requiredPhone),
              _field('ที่อยู่ (บ้านเลขที่/หมู่/ถนน/ตำบล)', _line1, TextInputType.streetAddress),
              _field('อำเภอ/เขต', _district, TextInputType.streetAddress),
              _field('จังหวัด', _province, TextInputType.streetAddress),
              _field('รหัสไปรษณีย์', _zip, TextInputType.number,
                  validator: _requiredZip),
            ],
          ),
        ),
      ),

      // ปุ่มบันทึกลอยด้านล่าง
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final addr = ShippingAddress(
                    name: _name.text.trim(),
                    phone: _phone.text.trim(),
                    line1: _line1.text.trim(),
                    district: _district.text.trim(),
                    province: _province.text.trim(),
                    zip: _zip.text.trim(),
                  );
                  Navigator.pop(context, addr); // ส่งค่ากลับไปหน้า Checkout
                }
              },
              child: const Text('บันทึกที่อยู่', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
    );
  }

  // ===== helpers =====

  Widget _field(
    String label,
    TextEditingController c,
    TextInputType type, {
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        validator: validator ?? _required,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF6F6F6),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'โปรดกรอกข้อมูล' : null;

  String? _requiredPhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'โปรดกรอกเบอร์โทร';
    if (v.trim().length < 9) return 'เบอร์ไม่ถูกต้อง';
    return null;
  }

  String? _requiredZip(String? v) {
    if (v == null || v.trim().isEmpty) return 'โปรดกรอกรหัสไปรษณีย์';
    if (v.trim().length < 5) return 'รหัสไปรษณีย์ไม่ถูกต้อง';
    return null;
  }
}
