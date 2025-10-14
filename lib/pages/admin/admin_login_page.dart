import 'package:flutter/material.dart';
import '../../services/admin_auth_service.dart';
import 'admin_dashboard.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminNameController = TextEditingController();

  bool _isLoading = false;
  bool _isSignUpMode = false;
  bool _obscurePassword = true;

  // Admin emails ที่อนุญาต
  final List<String> _allowedEmails = [
    'admin@gmail.com',
    'anucha.suks@gmail.com',
    'yatawikhadi@gmail.com',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _adminNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple[800]!,
              Colors.purple[600]!,
              Colors.purple[400]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo และ Title
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.purple[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 48,
                            color: Colors.purple[800],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          _isSignUpMode ? 'สมัคร Admin' : 'เข้าสู่ระบบ Admin',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          _isSignUpMode 
                              ? 'สร้างบัญชี Admin ใหม่'
                              : 'เข้าถึงระบบจัดการสินค้า',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ชื่อ Admin (เฉพาะ Sign Up)
                        if (_isSignUpMode) ...[
                          _buildTextField(
                            controller: _adminNameController,
                            label: 'ชื่อ Admin',
                            hint: 'กรอกชื่อของคุณ',
                            icon: Icons.person,
                            validator: (value) {
                              if (_isSignUpMode && (value == null || value.trim().isEmpty)) {
                                return 'กรุณากรอกชื่อ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // อีเมล
                        _buildTextField(
                          controller: _emailController,
                          label: 'อีเมล Admin',
                          hint: 'admin@example.com',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณากรอกอีเมล';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'รูปแบบอีเมลไม่ถูกต้อง';
                            }
                            if (!_allowedEmails.contains(value.toLowerCase())) {
                              return 'อีเมลนี้ไม่มีสิทธิ์เข้าถึงระบบ Admin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // รหัสผ่าน
                        _buildTextField(
                          controller: _passwordController,
                          label: 'รหัสผ่าน',
                          hint: 'กรอกรหัสผ่าน',
                          icon: Icons.lock,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกรหัสผ่าน';
                            }
                            if (value.length < 6) {
                              return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // ปุ่มเข้าสู่ระบบ/สมัครสมาชิก
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    _isSignUpMode ? 'สมัครสมาชิก' : 'เข้าสู่ระบบ',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // สลับโหมด
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isSignUpMode ? 'มีบัญชีแล้ว?' : 'ยังไม่มีบัญชี?',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _isSignUpMode = !_isSignUpMode),
                              child: Text(
                                _isSignUpMode ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก',
                                style: TextStyle(
                                  color: Colors.purple[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ลืมรหัสผ่าน
                        if (!_isSignUpMode)
                          TextButton(
                            onPressed: _handleForgotPassword,
                            child: Text(
                              'ลืมรหัสผ่าน?',
                              style: TextStyle(
                                color: Colors.purple[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // ข้อมูล Admin Emails ที่อนุญาต
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'อีเมล Admin ที่อนุญาต',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ..._allowedEmails.map((email) => Padding(
                                padding: const EdgeInsets.only(left: 24, bottom: 2),
                                child: Text(
                                  '• $email',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple[800]!, width: 2),
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      AdminAuthResult result;
      
      if (_isSignUpMode) {
        result = await AdminAuthService.signUpAdmin(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          adminName: _adminNameController.text.trim(),
        );
      } else {
        result = await AdminAuthService.signInAdmin(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isSignUpMode ? 'สมัครสมาชิกสำเร็จ!' : 'เข้าสู่ระบบสำเร็จ!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          
          // ไปที่ Admin Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'เกิดข้อผิดพลาด'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกอีเมลก่อน'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await AdminAuthService.resetPassword(_emailController.text.trim());
    
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ส่งอีเมลรีเซ็ตรหัสผ่านแล้ว กรุณาตรวจสอบอีเมล'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'เกิดข้อผิดพลาด'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
