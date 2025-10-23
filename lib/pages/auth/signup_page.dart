import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _obscure = true, _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      // สมัครผู้ใช้ใหม่
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text,
      );

      // ออกจากระบบ เพื่อให้ต้องล็อกอินเอง
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      // กลับไปหน้า Login พร้อมส่งอีเมลไปเติมอัตโนมัติ
      Navigator.pushReplacementNamed(
        context,
        '/login',
        arguments: {'email': _email.text.trim()},
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'สมัครไม่สำเร็จ';
      if (e.code == 'email-already-in-use') {
        msg = 'อีเมลนี้ถูกใช้ไปแล้ว';
      } else if (e.code == 'invalid-email') {
        msg = 'อีเมลไม่ถูกต้อง';
      } else if (e.code == 'weak-password') {
        msg = 'รหัสผ่านอย่างน้อย 6 ตัวอักษร';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration deco(String label, IconData icon, {Widget? suffix}) =>
        InputDecoration(labelText: label, prefixIcon: Icon(icon), suffixIcon: suffix);

    return Scaffold(
      appBar: AppBar(title: const Text('สมัครสมาชิก'), centerTitle: true),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: deco('อีเมล', Icons.mail_outline),
                validator: (v) {
                  final t = (v ?? '').trim();
                  final ok = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(t);
                  return ok ? null : 'อีเมลไม่ถูกต้อง';
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _pass,
                obscureText: _obscure,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  suffix: IconButton(
                    icon: Icon(_obscure
                    ? Icons.visibility_off
                    : Icons.visibility),
                    onPressed: () => setState(() =>_obscure = _obscure),
                  ),
                ),
                validator: (v) =>
                    (v != null && v.length >= 6) ? null : 'อย่างน้อย 6 ตัวอักษร',
                onFieldSubmitted: (_) => _signup(),
              ),
              
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  child: _loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('สมัครสมาชิก'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loading ? null : () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('มีบัญชีอยู่แล้ว? เข้าสู่ระบบ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
