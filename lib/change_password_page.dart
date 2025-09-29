import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController(text: 'yatavee@gmail.com');
  final _oldPass = TextEditingController(text: 'yatavee1234');
  final _newPass = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _email.dispose();
    _oldPass.dispose();
    _newPass.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'โปรดกรอกอีเมล';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    return ok ? null : 'รูปแบบอีเมลไม่ถูกต้อง';
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFBF6F4);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('เปลี่ยนรหัสผ่าน'),
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
                      'เปลี่ยนรหัสผ่าน',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 22),

                    // email
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

                    // old password
                    const Text('รหัสผ่านเดิม',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    _PillTextField(
                      controller: _oldPass,
                      hint: 'กรอกรหัสผ่านเดิม',
                      obscureText: _obscureOld,
                      suffix: IconButton(
                        icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureOld = !_obscureOld),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'โปรดกรอกรหัสผ่านเดิม' : null,
                    ),
                    const SizedBox(height: 14),

                    // new password
                    const Text('รหัสผ่านใหม่',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    _PillTextField(
                      controller: _newPass,
                      hint: 'กรอกรหัสผ่านใหม่',
                      obscureText: _obscureNew,
                      suffix: IconButton(
                        icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'โปรดกรอกรหัสผ่านใหม่';
                        if (v == _oldPass.text) return 'รหัสผ่านใหม่ต้องต่างจากเดิม';
                        if (v.length < 6) return 'รหัสผ่านควรมีอย่างน้อย 6 ตัวอักษร';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // button
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
                            // TODO: call API เปลี่ยนรหัสผ่านจริง
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('เปลี่ยนรหัสผ่านสำเร็จ')),
                            );
                            Navigator.pop(context); // กลับไปหน้าเดิม (Login)
                          }
                        },
                        // ถ้าต้องการให้ข้อความบนปุ่มเป็น "เข้าสู่ระบบ" เหมือนภาพ ให้แก้ด้านล่างนี้
                        child: const Text('เปลี่ยนรหัสผ่าน',
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
