import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCollectionSetupService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  // Admin email ที่อนุญาต
  static const List<String> _adminEmails = [
    'admin@gmail.com',
    'anucha.suks@gmail.com',
    'yatawikhadi@gmail.com',
  ];

  /// สร้าง collection admins และ admin user เริ่มต้น
  static Future<AdminSetupResult> setupAdminsCollection() async {
    try {
      print('🔧 เริ่มต้นการสร้าง collection admins...');

      // ตรวจสอบว่า collection admins มีอยู่แล้วหรือไม่
      final existingAdmins = await _firestore.collection('admins').limit(1).get();
      if (existingAdmins.docs.isNotEmpty) {
        return AdminSetupResult.success('Collection admins มีอยู่แล้ว');
      }

      // สร้าง admin user เริ่มต้น
      await _createInitialAdminUsers();

      return AdminSetupResult.success('สร้าง collection admins และ admin users เริ่มต้นสำเร็จ');
    } catch (e) {
      print('❌ Error setting up admins collection: $e');
      return AdminSetupResult.failure('เกิดข้อผิดพลาด: $e');
    }
  }

  /// สร้าง admin users เริ่มต้น
  static Future<void> _createInitialAdminUsers() async {
    print('👥 สร้าง admin users เริ่มต้น...');

    // สร้าง admin users สำหรับแต่ละ email ใน whitelist
    for (final email in _adminEmails) {
      try {
        // สร้าง admin profile ใน Firestore
        final adminId = _generateAdminId(email);
        await _firestore.collection('admins').doc(adminId).set({
          'uid': adminId,
          'email': email,
          'name': _getAdminName(email),
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'lastLoginAt': null,
          'createdBy': 'system',
          'isInitialAdmin': true,
        });

        print('✅ สร้าง admin profile สำหรับ $email สำเร็จ');
      } catch (e) {
        print('⚠️ ไม่สามารถสร้าง admin profile สำหรับ $email: $e');
      }
    }
  }

  /// สร้าง Firebase Auth user สำหรับ admin
  static Future<AdminSetupResult> createAuthUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // ตรวจสอบว่าเป็น admin email หรือไม่
      if (!_adminEmails.contains(email.toLowerCase())) {
        return AdminSetupResult.failure('อีเมลนี้ไม่มีสิทธิ์เป็น admin');
      }

      // ตรวจสอบว่า user มีอยู่ใน Firebase Auth หรือไม่
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(email);
        if (methods.isNotEmpty) {
          return AdminSetupResult.failure('อีเมลนี้มีอยู่ใน Firebase Auth แล้ว');
        }
      } catch (e) {
        // Email ไม่มีใน Firebase Auth
      }

      // สร้าง user ใน Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // อัปเดตข้อมูลผู้ใช้
        await credential.user!.updateDisplayName(name);

        // สร้าง admin profile ใน Firestore
        await _firestore.collection('admins').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'name': name,
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'lastLoginAt': null,
          'createdBy': 'manual_setup',
        });

        return AdminSetupResult.success('สร้าง admin user สำเร็จ');
      } else {
        return AdminSetupResult.failure('ไม่สามารถสร้าง user ได้');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'อีเมลนี้ถูกใช้งานแล้ว';
          break;
        case 'weak-password':
          errorMessage = 'รหัสผ่านไม่แข็งแรงพอ';
          break;
        case 'invalid-email':
          errorMessage = 'รูปแบบอีเมลไม่ถูกต้อง';
          break;
        default:
          errorMessage = 'เกิดข้อผิดพลาด: ${e.message}';
      }
      return AdminSetupResult.failure(errorMessage);
    } catch (e) {
      return AdminSetupResult.failure('เกิดข้อผิดพลาดที่ไม่คาดคิด: $e');
    }
  }

  /// ตรวจสอบสถานะ collection admins
  static Future<AdminCollectionStatus> checkAdminsCollectionStatus() async {
    try {
      // ตรวจสอบ collection admins
      final snapshot = await _firestore.collection('admins').limit(1).get();
      final hasAdminsCollection = snapshot.docs.isNotEmpty;

      // ตรวจสอบ admin users
      final adminsSnapshot = await _firestore.collection('admins').get();
      final adminUsers = adminsSnapshot.docs.map((doc) {
        final data = doc.data();
        return AdminUserInfo(
          uid: doc.id,
          email: data['email'] ?? '',
          name: data['name'] ?? '',
          isActive: data['isActive'] ?? false,
          createdAt: data['createdAt']?.toDate(),
        );
      }).toList();

      return AdminCollectionStatus(
        hasCollection: hasAdminsCollection,
        adminCount: adminUsers.length,
        adminUsers: adminUsers,
      );
    } catch (e) {
      print('Error checking admins collection status: $e');
      return AdminCollectionStatus(
        hasCollection: false,
        adminCount: 0,
        adminUsers: [],
      );
    }
  }

  /// ลบ collection admins ทั้งหมด
  static Future<AdminSetupResult> deleteAdminsCollection() async {
    try {
      print('🗑️ ลบ collection admins...');

      final batch = _firestore.batch();
      final snapshot = await _firestore.collection('admins').get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      return AdminSetupResult.success('ลบ collection admins สำเร็จ');
    } catch (e) {
      print('Error deleting admins collection: $e');
      return AdminSetupResult.failure('เกิดข้อผิดพลาด: $e');
    }
  }

  /// สร้าง Admin ID
  static String _generateAdminId(String email) {
    // ใช้ email hash เป็น ID หรือ timestamp
    return email.replaceAll('@', '_').replaceAll('.', '_') + '_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// ได้ชื่อ Admin จาก email
  static String _getAdminName(String email) {
    switch (email.toLowerCase()) {
      case 'admin@gmail.com':
        return 'System Admin';
      case 'anucha.suks@gmail.com':
        return 'Anucha Suks';
      case 'yatawikhadi@gmail.com':
        return 'Yatawikhadi';
      default:
        return 'Admin User';
    }
  }

  /// รีเซ็ต collection admins
  static Future<AdminSetupResult> resetAdminsCollection() async {
    try {
      print('🔄 รีเซ็ต collection admins...');

      // ลบ collection เดิม
      final deleteResult = await deleteAdminsCollection();
      if (!deleteResult.success) {
        return deleteResult;
      }

      // สร้างใหม่
      return await setupAdminsCollection();
    } catch (e) {
      print('Error resetting admins collection: $e');
      return AdminSetupResult.failure('เกิดข้อผิดพลาด: $e');
    }
  }
}

/// ผลลัพธ์การตั้งค่า Admin
class AdminSetupResult {
  final bool success;
  final String message;

  AdminSetupResult._(this.success, this.message);

  factory AdminSetupResult.success(String message) => AdminSetupResult._(true, message);
  factory AdminSetupResult.failure(String message) => AdminSetupResult._(false, message);
}

/// สถานะ collection admins
class AdminCollectionStatus {
  final bool hasCollection;
  final int adminCount;
  final List<AdminUserInfo> adminUsers;

  AdminCollectionStatus({
    required this.hasCollection,
    required this.adminCount,
    required this.adminUsers,
  });
}

/// ข้อมูล Admin User
class AdminUserInfo {
  final String uid;
  final String email;
  final String name;
  final bool isActive;
  final DateTime? createdAt;

  AdminUserInfo({
    required this.uid,
    required this.email,
    required this.name,
    required this.isActive,
    this.createdAt,
  });
}






