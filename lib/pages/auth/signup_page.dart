import 'package:flutter/material.dart';      
import 'package:firebase_auth/firebase_auth.dart'; 


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final _form = GlobalKey<FormState>(); // ใช้ตรวจว่าฟอร์มกรอกถูกไหม
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
    // เช็คว่าฟอร์มผ่านไหม (อีเมลถูกฟอร์แมต? รหัสยาวพอ?)
    if (!(_form.currentState?.validate() ?? false)) return;

    setState(() => _loading = true); 

    try {
      
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(), 
        password: _pass.text,
      );

      
      await FirebaseAuth.instance.signOut();

      if (!mounted) return; 

      // ย้อนกลับ
      Navigator.pushReplacementNamed(
        context,
        '/login',
        arguments: {'email': _email.text.trim()},
      );
    }
    
     on FirebaseAuthException catch (e) {
      // ถ้าเกิด error ตอนสมัคร เช่น อีเมลซ้ำ รหัสอ่อนเกิน
      String msg = 'สมัครไม่สำเร็จ';

      if (e.code == 'email-already-in-use') {
        msg = 'อีเมลนี้ถูกใช้ไปแล้ว';         
      } else if (e.code == 'invalid-email') {
        msg = 'อีเมลไม่ถูกต้อง';            
      } else if (e.code == 'weak-password') {
        msg = 'รหัสผ่านอย่างน้อย 6 ตัวอักษร'; 
      }

      // โชว์ข้อความแจ้งเตือนด้านล่างจอ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ฟังก์ชันช่วยสร้าง InputDecoration (หน้าตาช่องกรอก)
    InputDecoration deco(String label, IconData icon, {Widget? suffix}) =>
        InputDecoration(
          labelText: label,       
          prefixIcon: Icon(icon),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิก'), 
        centerTitle: true, 
      ),
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
                  final t = (v ?? '').trim(); // ข้อความที่ผู้ใช้กรอก
                  final ok = RegExp(  //RegExp = กรองข้อความ ดูว่าตรงรูปแบบที่เรายอมรับไหม (เช่น อีเมลถูกไหม)
                    r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$'
                  ).hasMatch(t); // เช็คว่าเป็นรูปแบบอีเมลจริงไหม
                  return ok ? null : 'อีเมลไม่ถูกต้อง';
                  // ถ้า null = ผ่าน, ถ้าไม่ null = โชว์ error ใต้ช่อง
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
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off 
                          : Icons.visibility,    
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
             
                  ),
                ),
                validator: (v) =>
                   
                    (v != null && v.length >= 6)
                        ? null
                        : 'อย่างน้อย 6 ตัวอักษร',
                onFieldSubmitted: (_) => _signup(),
                
              ),

              const SizedBox(height: 20),

             
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signup,
               
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                          // วงกลมหมุนแปลว่ากำลังสมัครอยู่
                        )
                      : const Text('สมัครสมาชิก'),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.pushReplacementNamed(context, '/login'),
                // กลับไปหน้า login แทนหน้านี้ (กด back จะไม่ย้อนกลับมาหน้า signup อีก)
                child: const Text('มีบัญชีอยู่แล้ว? เข้าสู่ระบบ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

