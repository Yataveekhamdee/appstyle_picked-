import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

Future<void> ensureUserDoc(User user) async {
  final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final snap = await ref.get();
  if (!snap.exists) {
    await ref.set({
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName ?? '',
      'photoURL': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'role': 'customer',
    });
  }
}


class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final pass  = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  // รับอีเมลที่ถูกส่งมาจากหน้า signup เพื่อเติมอัตโนมัติ
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['email'] is String) {
      email.text = args['email'] as String;
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: pass.text,
      );

      final user = FirebaseAuth.instance.currentUser!;
    await ensureUserDoc(user);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on FirebaseAuthException catch (e) {
      var msg = 'เข้าสู่ระบบไม่สำเร็จ';
      if (e.code == 'user-not-found') msg = 'ไม่พบบัญชีผู้ใช้นี้';
      if (e.code == 'wrong-password') msg = 'รหัสผ่านไม่ถูกต้อง';
      if (e.code == 'invalid-email')  msg = 'อีเมลไม่ถูกต้อง';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goSignup() => Navigator.pushReplacementNamed(context, '/signup');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('เข้าสู่ระบบ',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const CircleAvatar(radius: 38, child: Icon(Icons.shopping_bag, size: 40)),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'อีเมล'),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return 'กรุณากรอกอีเมล';
                        final ok = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(t);
                        return ok ? null : 'รูปแบบอีเมลไม่ถูกต้อง';
                      },
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: pass,
                      obscureText: _obscure,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.visiblePassword,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'รหัสผ่าน',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'กรุณากรอกรหัสผ่าน' : null,
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('เข้าสู่ระบบ'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loading ? null : _goSignup,
                      child: const Text('ยังไม่มีบัญชี? สมัครเลย'),
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
