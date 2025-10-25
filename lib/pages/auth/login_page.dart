import 'package:flutter/material.dart';            
import 'package:firebase_auth/firebase_auth.dart'; //
import 'package:cloud_firestore/cloud_firestore.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}


Future<void> ensureUserDoc(User user) async {
  final ref = FirebaseFirestore.instance.collection('users').doc(user.uid); // ชี้ไปที่ users/<uid>
  final snap = await ref.get(); // ดึงข้อมูลดูว่ามีมั้ย
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
  final _formKey = GlobalKey<FormState>(); // เอาไว้เช็ค validation ของฟอร์ม (กรอกถูกไหม)
  final email = TextEditingController();   // ตัวควบคุมช่องอีเมล
  final pass  = TextEditingController();   // ตัวควบคุมช่องรหัสผ่าน

  bool _loading = false; 
  bool _obscure = true;  

  @override
  void dispose() {

    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true); // เปิดโหมดกำลังโหลด

    try {
     
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: pass.text,
      );

      // ดึง user ที่ล็อกอินสำเร็จ
      final user = FirebaseAuth.instance.currentUser!;

      
      await ensureUserDoc(user);

      if (!mounted) return;

      // ไปหน้า '/home' แล้วล้างประวัติหน้าเก่าออก (กด back จะไม่ย้อนกลับมาล็อกอิน)
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);

    } on FirebaseAuthException catch (e) {
      
      var msg = 'เข้าสู่ระบบไม่สำเร็จ'; 

      if (e.code == 'user-not-found') msg = 'ไม่พบบัญชีผู้ใช้นี้'; // ไม่มีอีเมลนี้ในระบบ
      if (e.code == 'wrong-password') msg = 'รหัสผ่านไม่ถูกต้อง'; // พิมพ์รหัสผิด
      if (e.code == 'invalid-email')  msg = 'อีเมลไม่ถูกต้อง';    // ฟอร์แมตอีเมลไม่ถูก

      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      
      if (mounted) setState(() => _loading = false);
    }
  }

  // ไปหน้า signup (แทนหน้าเดิมเลย)
  void _goSignup() => Navigator.pushReplacementNamed(context, '/signup');

  @override
  Widget build(BuildContext context) {
    // สร้าง UI ของหน้านี้
    return Scaffold(
      body: SafeArea( // กันไม่ให้ไปทับขอบจอ (เช่นติ่งกล้อง)
        child: Center(
          child: SingleChildScrollView( // เผื่อจอเล็ก เลื่อนขึ้นลงได้ ไม่ล้น
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420), // ตีกรอบความกว้างฟอร์มให้ดูสวยทั้งมือถือ/เว็บ
              child: Form(
                key: _formKey, // ผูกกับตัวฟอร์มเพื่อใช้ validate()
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'เข้าสู่ระบบ',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // ไอคอนวงกลมด้านบน (โลโก้ / placeholder)
                    const CircleAvatar(
                      radius: 38,
                      child: Icon(Icons.shopping_bag, size: 40),
                    ),
                    const SizedBox(height: 24),

                    // ช่องกรอกอีเมล
                    TextFormField(
                      controller: email, // ผูกกับตัวแปร email
                      keyboardType: TextInputType.emailAddress, // คีย์บอร์ดแบบอีเมล
                      textInputAction: TextInputAction.next, // ปุ่มบนคีย์บอร์ดจะเป็น "Next"
                      decoration: const InputDecoration(labelText: 'อีเมล'),
                      validator: (v) {
                        // ฟังก์ชันเช็คความถูกต้อง
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return 'กรุณากรอกอีเมล'; // ห้ามว่าง
                        final ok = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(t);
                        return ok ? null : 'รูปแบบอีเมลไม่ถูกต้อง'; // รูปแบบไม่ใช่อีเมล
                      },
                    ),
                    const SizedBox(height: 10),

                    // ช่องกรอกรหัสผ่าน
                    TextFormField(
                      controller: pass,        // ผูกกับตัวแปร pass
                      obscureText: _obscure,   // ถ้า true จะแสดงเป็นจุด ••••
                      keyboardType: TextInputType.visiblePassword,
                      onFieldSubmitted: (_) => _login(), // กด Enter แล้วล็อกอินเลย
                      decoration: InputDecoration(
                        labelText: 'รหัสผ่าน',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                              ? Icons.visibility_off // ถ้ากำลังซ่อน ให้โชว์ไอคอน "ปิดตา"
                              : Icons.visibility,    // ถ้ากำลังโชว์ ให้โชว์ไอคอน "ตาเปิด"
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                          // กดปุ่มตา = สลับซ่อน/โชว์รหัสผ่าน
                        ),
                      ),
                      validator: (v) =>
                        (v == null || v.isEmpty) ? 'กรุณากรอกรหัสผ่าน' : null,
                        // ถ้าว่าง → error
                    ),

                    const SizedBox(height: 16),

                    // ปุ่ม "เข้าสู่ระบบ"
                    SizedBox(
                      width: double.infinity, // ให้ปุ่มกว้างเต็มแถว
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        // ถ้า _loading = true ปุ่มจะกดไม่ได้ (null)
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                                // วงกลมหมุนตอนกำลังล็อกอิน
                              )
                            : const Text('เข้าสู่ระบบ'),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ปุ่มไปหน้าสมัครสมาชิก
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

