import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_auth_provider.dart';
import '../../services/admin_management_service.dart';

class AdminManagementPage extends StatefulWidget {
  const AdminManagementPage({super.key});

  @override
  State<AdminManagementPage> createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> {
  List<AdminUser> _admins = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final admins = await AdminManagementService.getAllAdmins();
      setState(() {
        _admins = admins;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการ Admin Users', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAdmins,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'ข้อมูลสำคัญ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'หากพบปัญหา "อีเมลถูกใช้แล้ว" ให้ลบ user จาก Firebase Console ก่อน\n'
                  '1. ไปที่ Firebase Console > Authentication > Users\n'
                  '2. หา user ที่มีปัญหา\n'
                  '3. กดปุ่ม "Delete user"',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Admin List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'เกิดข้อผิดพลาด',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red.shade600),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAdmins,
                              child: const Text('ลองใหม่'),
                            ),
                          ],
                        ),
                      )
                    : _admins.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.admin_panel_settings_outlined, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  'ไม่มี Admin Users',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ยังไม่มี admin users ในระบบ',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _admins.length,
                            itemBuilder: (context, index) {
                              final admin = _admins[index];
                              return _buildAdminCard(admin);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAdminDialog(),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่ม Admin'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAdminCard(AdminUser admin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: admin.isActive ? Colors.green : Colors.red,
                  child: Text(
                    admin.name.isNotEmpty ? admin.name[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        admin.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: admin.isActive ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    admin.isActive ? 'ใช้งาน' : 'ปิดใช้งาน',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: admin.isActive ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  'สร้างเมื่อ: ${_formatDate(admin.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const Spacer(),
                if (admin.lastLoginAt != null) ...[
                  Icon(Icons.login, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'เข้าสู่ระบบล่าสุด: ${_formatDate(admin.lastLoginAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteAdminDialog(admin),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('ลบ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade300),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleAdminStatus(admin),
                    icon: Icon(
                      admin.isActive ? Icons.block : Icons.check_circle,
                      size: 16,
                    ),
                    label: Text(admin.isActive ? 'ปิดใช้งาน' : 'เปิดใช้งาน'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: admin.isActive ? Colors.orange : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAdminDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่ม Admin User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'อีเมล',
                hintText: 'admin@example.com',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อ',
                hintText: 'ชื่อ Admin',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'รหัสผ่าน',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => _createAdmin(
              emailController.text,
              passwordController.text,
              nameController.text,
            ),
            child: const Text('สร้าง'),
          ),
        ],
      ),
    );
  }

  Future<void> _createAdmin(String email, String password, String name) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      _showErrorDialog('กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }

    Navigator.pop(context); // ปิด dialog

    // แสดง loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final currentUser = context.read<AdminAuthProvider>().currentUser;
      final result = await AdminManagementService.createAdminUser(
        email: email,
        password: password,
        adminName: name,
        adminEmail: currentUser?.email ?? '',
      );

      Navigator.pop(context); // ปิด loading

      if (result.success) {
        _showSuccessDialog(result.message);
        _loadAdmins();
      } else {
        _showErrorDialog(result.message);
      }
    } catch (e) {
      Navigator.pop(context); // ปิด loading
      _showErrorDialog('เกิดข้อผิดพลาด: $e');
    }
  }

  void _showDeleteAdminDialog(AdminUser admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบ Admin User'),
        content: Text('คุณแน่ใจหรือไม่ที่จะลบ ${admin.name} (${admin.email})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => _deleteAdmin(admin),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAdmin(AdminUser admin) async {
    Navigator.pop(context); // ปิด dialog

    // แสดง loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final currentUser = context.read<AdminAuthProvider>().currentUser;
      final result = await AdminManagementService.deleteAdminUser(
        email: admin.email,
        adminEmail: currentUser?.email ?? '',
      );

      Navigator.pop(context); // ปิด loading

      if (result.success) {
        _showInfoDialog(result.message);
        _loadAdmins();
      } else {
        _showErrorDialog(result.message);
      }
    } catch (e) {
      Navigator.pop(context); // ปิด loading
      _showErrorDialog('เกิดข้อผิดพลาด: $e');
    }
  }

  Future<void> _toggleAdminStatus(AdminUser admin) async {
    // แสดง loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final currentUser = context.read<AdminAuthProvider>().currentUser;
      final result = await AdminManagementService.updateAdminStatus(
        uid: admin.uid,
        isActive: !admin.isActive,
        adminEmail: currentUser?.email ?? '',
      );

      Navigator.pop(context); // ปิด loading

      if (result.success) {
        _loadAdmins();
      } else {
        _showErrorDialog(result.message);
      }
    } catch (e) {
      Navigator.pop(context); // ปิด loading
      _showErrorDialog('เกิดข้อผิดพลาด: $e');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('สำเร็จ'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('เกิดข้อผิดพลาด'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('ข้อมูล'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'ไม่ทราบ';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}






