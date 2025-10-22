// lib/pages/admin/admin_login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_dashboard.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _busy = false, _hide = true;

  static const _admins = {'admin@gmail.com', 'yatawikhadi@gmail.com'};

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  String? _vEmail(String? v) {
    final s = v?.trim().toLowerCase() ?? '';
    if (s.isEmpty) return 'กรุณากรอกอีเมล';
    if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(s))
      return 'อีเมลไม่ถูกต้อง';
    if (!_admins.contains(s)) return 'อีเมลนี้ไม่มีสิทธิ์ Admin';
    return null;
  }

  String? _vPass(String? v) => (v == null || v.isEmpty)
      ? 'กรุณากรอกรหัสผ่าน'
      : (v.length < 6 ? 'อย่างน้อย 6 ตัว' : null);

  Future<void> _signIn() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final email = _email.text.trim().toLowerCase();
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _pass.text,
      );
      final ok = _admins.contains(cred.user?.email?.toLowerCase() ?? '');
      if (!ok) {
        await FirebaseAuth.instance.signOut();
        _snack('บัญชีนี้ไม่ใช่ผู้ดูแลระบบ', true);
        return;
      }
      if (!mounted) return;
      _snack('เข้าสู่ระบบสำเร็จ!');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
    } on FirebaseAuthException catch (e) {
      _snack(e.message ?? e.code, true);
    } catch (e) {
      _snack('เกิดข้อผิดพลาด: $e', true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    final e = _email.text.trim();
    if (e.isEmpty) return _snack('กรุณากรอกอีเมลก่อน');
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: e);
      _snack('ส่งลิงก์รีเซ็ตรหัสผ่านแล้ว');
    } on FirebaseAuthException catch (x) {
      _snack(x.message ?? x.code, true);
    }
  }

  void _snack(String m, [bool err = false]) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(m), backgroundColor: err ? Colors.red : null));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เข้าสู่ระบบ Admin'),
        leading: BackButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('เข้าสู่ระบบ Admin',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: _vEmail,
                  decoration: const InputDecoration(
                      labelText: 'อีเมล', prefixIcon: Icon(Icons.email)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pass,
                  obscureText: _hide,   
                  validator: _vPass,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon:
                          Icon(_hide ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _hide = !_hide),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _signIn,
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('เข้าสู่ระบบ'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
