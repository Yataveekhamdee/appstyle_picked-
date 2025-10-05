import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // ===== ไปหน้า "บัญชีผู้ใช้" พร้อมส่งข้อมูลเริ่มต้น =====
  void _goAccount({String? name, String? email, String? avatarPath}) {
    Navigator.pushReplacementNamed(
      context,
      '/account',
      arguments: {
        'name': name ?? '',
        'email': email ?? '',
        'avatarPath': avatarPath ?? '',
      },
    );
  }

  // ===== เข้าสู่ระบบด้วยอีเมล/รหัสผ่าน =====
  void _signInEmail() {
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) {
      _snack('กรอกอีเมลและรหัสผ่าน'); 
      return;
    }
    _goAccount(
      name: 'ผู้ใช้',
      email: _email.text.trim(),
    );
  }

  // ===== โซเชียล (เด้งไปหน้าบัญชีผู้ใช้) =====
  void _signInGoogle() {
    _goAccount(
      name: 'ผู้ใช้ Google',
      email: 'google@example.com',
      // avatarPath: '.../path.jpg', // ถ้ามี
    );
  }

  void _signInFacebook() {
    _goAccount(
      name: 'ผู้ใช้ Facebook',
      email: 'facebook@example.com',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minH = constraints.maxHeight;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minH),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    Row(
                      children: const [
                        SizedBox(width: 48),
                        Expanded(
                          child: Text(
                            'เข้าสู่ระบบ',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                        ),
                        SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _logo(cs),
                    const SizedBox(height: 24),

                    _card(
                      cs: cs,
                      children: [
                        _underlineField(
                          controller: _email,
                          label: 'E-mail/เบอร์/ชื่อผู้ใช้',
                          prefix: const Icon(Icons.person_outline),
                          keyboard: TextInputType.emailAddress,
                          focusColor: cs.primary,
                        ),
                        const SizedBox(height: 12),
                        _underlineField(
                          controller: _pass,
                          label: 'รหัสผ่าน',
                          prefix: const Icon(Icons.lock_outline),
                          obscure: true,
                          focusColor: cs.primary,
                          trailing: TextButton(
                            onPressed: () {},
                            child: Text('ลืมรหัสผ่าน?', style: TextStyle(color: cs.primary)),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 48, width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _signInEmail,
                            child: const Text('เข้าสู่ระบบ',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _orDivider(),
                        const SizedBox(height: 14),
                        _socialBtn(
                          cs: cs,
                          icon: Icons.g_mobiledata,
                          label: 'ดำเนินการต่อด้วยบัญชี Google',
                          onTap: _signInGoogle,
                        ),
                        const SizedBox(height: 10),
                        _socialBtn(
                          cs: cs,
                          icon: Icons.facebook,
                          label: 'ดำเนินการต่อด้วย Facebook',
                          onTap: _signInFacebook,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                        child: Text(
                          'ยังไม่มีบัญชีผู้ใช้? สมัครเลย',
                          style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── small widgets ─────────────────────────
  Widget _logo(ColorScheme cs) => Center(
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
          child: const Icon(Icons.shopping_bag, color: Colors.white, size: 44),
        ),
      );

  Widget _card({required ColorScheme cs, required List<Widget> children}) =>
      Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEAEAEA)),
        ),
        child: Column(children: children),
      );

  Widget _underlineField({
    required TextEditingController controller,
    required String label,
    required Color focusColor,
    Widget? prefix,
    Widget? trailing,
    bool obscure = false,
    TextInputType? keyboard,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (prefix != null) ...[prefix, const SizedBox(width: 10)],
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboard,
            decoration: InputDecoration(
              labelText: label,
              border: const UnderlineInputBorder(),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: focusColor, width: 1.6),
              ),
              contentPadding: const EdgeInsets.only(bottom: 6),
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 6), trailing],
      ],
    );
  }

  Widget _orDivider() => Row(
        children: const [
          Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('หรือ', style: TextStyle(color: Colors.black54)),
          ),
          Expanded(child: Divider()),
        ],
      );

  Widget _socialBtn({
    required ColorScheme cs,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      SizedBox(
        height: 46,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 24, color: cs.primary),
          label: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: cs.primary, width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            foregroundColor: cs.primary,
          ),
        ),
      );
}
