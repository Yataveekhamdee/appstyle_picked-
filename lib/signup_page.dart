import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _name  = TextEditingController();
  final _email = TextEditingController();
  final _pass  = TextEditingController();

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // TODO: ต่อแบ็กเอนด์จริงในภายหลัง
  void _signUp() {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _pass.text.isEmpty) {
      _snack('กรอกข้อมูลให้ครบ'); return;
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _signInGoogle()   => Navigator.pushReplacementNamed(context, '/home');
  void _signInFacebook() => Navigator.pushReplacementNamed(context, '/home');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                ),
                const Expanded(
                  child: Text('สมัครสมาชิก', textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 12),
            _logo(),

            _card(children: [
              _underlineField(controller: _name,  label: 'ชื่อผู้ใช้',
                prefix: const Icon(Icons.badge_outlined)),
              const SizedBox(height: 8),
              _underlineField(controller: _email, label: 'อีเมล',
                prefix: const Icon(Icons.mail_outline),
                keyboard: TextInputType.emailAddress),
              const SizedBox(height: 8),
              _underlineField(controller: _pass,  label: 'รหัสผ่าน',
                prefix: const Icon(Icons.lock_outline), obscure: true),
              const SizedBox(height: 14),
              SizedBox(
                height: 48, width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D2D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('สมัครสมาชิก', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 12),
              _orDivider(),
              const SizedBox(height: 12),
              _socialBtn(icon: Icons.g_mobiledata, label: 'ดำเนินการต่อด้วยบัญชี Google', onTap: _signInGoogle),
              const SizedBox(height: 10),
              _socialBtn(icon: Icons.facebook, label: 'ดำเนินการต่อด้วย Facebook', onTap: _signInFacebook),
            ]),

            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('มีบัญชีอยู่แล้ว? เข้าสู่ระบบ',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── small widgets (เหมือน LoginPage) ─────────────────────────
  Widget _logo() => Center(
    child: Container(
      width: 72, height: 72,
      decoration: const BoxDecoration(color: Color(0xFFFF4D2D), shape: BoxShape.circle),
      child: const Icon(Icons.shopping_bag, color: Colors.white, size: 42),
    ),
  );

  Widget _card({required List<Widget> children}) => Container(
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFEAEAEA))),
    child: Column(children: children),
  );

  Widget _underlineField({
    required TextEditingController controller,
    required String label,
    Widget? prefix, bool obscure = false, TextInputType? keyboard,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (prefix != null) ...[prefix, const SizedBox(width: 8)],
        Expanded(
          child: TextField(
            controller: controller, obscureText: obscure, keyboardType: keyboard,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
            ).copyWith(labelText: label),
          ),
        ),
      ],
    );
  }

  Widget _orDivider() => Row(
    children: const [
      Expanded(child: Divider()),
      Padding(padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text('หรือ', style: TextStyle(color: Colors.black54))),
      Expanded(child: Divider()),
    ],
  );

  Widget _socialBtn({required IconData icon, required String label, required VoidCallback onTap}) =>
      SizedBox(
        height: 46,
        child: OutlinedButton.icon(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFE0E0E0)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            foregroundColor: Colors.black87,
          ),
          icon: Icon(icon, size: 24),
          label: Text(label, overflow: TextOverflow.ellipsis),
        ),
      );
}
