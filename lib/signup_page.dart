import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'โปรดกรอกอีเมล';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    return ok ? null : 'รูปแบบอีเมลไม่ถูกต้อง';
  }

  String? _validatePhone(String? v) {
    if (v == null || v.isEmpty) return 'โปรดกรอกเบอร์โทรศัพท์';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 9 ? null : 'กรอกเบอร์ให้ครบถ้วน';
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFFBF6F4);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('สมัครสมาชิก'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: _AuthCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),
                    const Text(
                      'สมัครสมาชิก',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 22),

                    const Text('ชื่อ',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    _PillTextField(
                      controller: _name,
                      hint: 'กรอกชื่อ',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'โปรดกรอกชื่อ' : null,
                    ),
                    const SizedBox(height: 14),

                    const Text('เบอร์โทรศัพท์',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    _PillTextField(
                      controller: _phone,
                      hint: 'กรอกเบอร์โทรศัพท์',
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 14),

                    const Text('อีเมล',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    _PillTextField(
                      controller: _email,
                      hint: 'กรอกอีเมล',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 14),

                    const Text('รหัสผ่าน',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    _PillTextField(
                      controller: _password,
                      hint: 'กรอกรหัสผ่าน',
                      obscureText: _obscure1,
                      suffix: IconButton(
                        icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure1 = !_obscure1),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'โปรดกรอกรหัสผ่าน' : null,
                    ),
                    const SizedBox(height: 14),

                    const Text('ยืนยันรหัสผ่าน',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    _PillTextField(
                      controller: _confirm,
                      hint: 'ยืนยันรหัสผ่าน',
                      obscureText: _obscure2,
                      suffix: IconButton(
                        icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure2 = !_obscure2),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'โปรดยืนยันรหัสผ่าน';
                        if (v != _password.text) return 'รหัสผ่านไม่ตรงกัน';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 44,
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor:
                              const MaterialStatePropertyAll(Colors.black),
                          foregroundColor:
                              const MaterialStatePropertyAll(Colors.white),
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: call API สมัครสมาชิกจริง
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('สมัครสมาชิกสำเร็จ')),
                            );
                            Navigator.pop(context); // กลับไปหน้าก่อนหน้า (Login)
                          }
                        },
                        child: const Text('สมัครสมาชิก',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// กล่องขาวมุมโค้ง + เงาอ่อน
class _AuthCard extends StatelessWidget {
  final Widget child;
  const _AuthCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 14, offset: Offset(0, 6)),
        ],
        border: Border.all(color: Color(0xFFE9E9E9), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
        child: child,
      ),
    );
  }
}

/// ช่องกรอกทรงเม็ดยา
class _PillTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _PillTextField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.black54, width: 1),
        ),
        suffixIcon: suffix,
      ),
    );
  }
}
