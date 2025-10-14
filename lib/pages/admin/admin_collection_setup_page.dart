import 'package:flutter/material.dart';
import '../../services/admin_collection_setup_service.dart';

class AdminCollectionSetupPage extends StatefulWidget {
  const AdminCollectionSetupPage({super.key});

  @override
  State<AdminCollectionSetupPage> createState() => _AdminCollectionSetupPageState();
}

class _AdminCollectionSetupPageState extends State<AdminCollectionSetupPage> {
  AdminCollectionStatus? _status;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkCollectionStatus();
  }

  Future<void> _checkCollectionStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final status = await AdminCollectionSetupService.checkAdminsCollectionStatus();
      setState(() {
        _status = status;
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
        title: const Text('ตั้งค่า Collection Admins', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkCollectionStatus,
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
                  'หน้านี้ใช้สำหรับสร้าง collection admins และ admin users เริ่มต้น\n'
                  'หาก collection ถูกลบไปแล้ว สามารถสร้างใหม่ได้ที่นี่',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Status Card
          if (_status != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _status!.hasCollection ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _status!.hasCollection ? Colors.green.shade200 : Colors.orange.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _status!.hasCollection ? Icons.check_circle : Icons.warning,
                        color: _status!.hasCollection ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _status!.hasCollection ? 'Collection มีอยู่แล้ว' : 'Collection ไม่มี',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _status!.hasCollection ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'จำนวน Admin Users: ${_status!.adminCount}',
                    style: TextStyle(
                      fontSize: 14,
                      color: _status!.hasCollection ? Colors.green.shade600 : Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // สร้าง Collection
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _setupCollection,
                    icon: const Icon(Icons.add_circle),
                    label: const Text('สร้าง Collection Admins'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // รีเซ็ต Collection
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _resetCollection,
                    icon: const Icon(Icons.refresh),
                    label: const Text('รีเซ็ต Collection'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: BorderSide(color: Colors.orange.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // สร้าง Auth User
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _showCreateAuthUserDialog,
                    icon: const Icon(Icons.person_add),
                    label: const Text('สร้าง Firebase Auth User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Admin Users List
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
                              onPressed: _checkCollectionStatus,
                              child: const Text('ลองใหม่'),
                            ),
                          ],
                        ),
                      )
                    : _status?.adminUsers.isEmpty == true
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
                                  'กดปุ่ม "สร้าง Collection Admins" เพื่อสร้าง admin users เริ่มต้น',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _status?.adminUsers.length ?? 0,
                            itemBuilder: (context, index) {
                              final admin = _status!.adminUsers[index];
                              return _buildAdminCard(admin);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(AdminUserInfo admin) {
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
                Text(
                  'UID: ${admin.uid.substring(0, 8)}...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setupCollection() async {
    // แสดง loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await AdminCollectionSetupService.setupAdminsCollection();

      Navigator.pop(context); // ปิด loading

      if (result.success) {
        _showSuccessDialog(result.message);
        _checkCollectionStatus();
      } else {
        _showErrorDialog(result.message);
      }
    } catch (e) {
      Navigator.pop(context); // ปิด loading
      _showErrorDialog('เกิดข้อผิดพลาด: $e');
    }
  }

  Future<void> _resetCollection() async {
    // แสดง confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('รีเซ็ต Collection'),
        content: const Text('คุณแน่ใจหรือไม่ที่จะรีเซ็ต collection admins? การดำเนินการนี้จะลบข้อมูลทั้งหมดแล้วสร้างใหม่'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('รีเซ็ต'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // แสดง loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await AdminCollectionSetupService.resetAdminsCollection();

      Navigator.pop(context); // ปิด loading

      if (result.success) {
        _showSuccessDialog(result.message);
        _checkCollectionStatus();
      } else {
        _showErrorDialog(result.message);
      }
    } catch (e) {
      Navigator.pop(context); // ปิด loading
      _showErrorDialog('เกิดข้อผิดพลาด: $e');
    }
  }

  void _showCreateAuthUserDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('สร้าง Firebase Auth User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'อีเมล',
                hintText: 'admin@gmail.com',
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
            onPressed: () => _createAuthUser(
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

  Future<void> _createAuthUser(String email, String password, String name) async {
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
      final result = await AdminCollectionSetupService.createAuthUser(
        email: email,
        password: password,
        name: name,
      );

      Navigator.pop(context); // ปิด loading

      if (result.success) {
        _showSuccessDialog(result.message);
        _checkCollectionStatus();
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'ไม่ทราบ';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}






