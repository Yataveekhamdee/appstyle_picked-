import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminManagementService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  // Admin email ที่อนุญาต
  static const List<String> _adminEmails = [
    'admin@gmail.com',
    'anucha.suks@gmail.com',
    'yatawikhadi@gmail.com',
    // เพิ่ม admin emails อื่นๆ ที่นี่
  ];

  /// ลบ Admin User ทั้งจาก Firebase Auth และ Firestore
  static Future<AdminManagementResult> deleteAdminUser({
    required String email,
    required String adminEmail, // อีเมลของ admin ที่ลบ
  }) async {
    try {
      // ตรวจสอบสิทธิ์ admin
      if (!_adminEmails.contains(adminEmail.toLowerCase())) {
        return AdminManagementResult.failure('ไม่มีสิทธิ์ลบ admin user');
      }

      // หา user จาก Firebase Auth
      final users = await _getUsersByEmail(email);
      if (users.isEmpty) {
        return AdminManagementResult.failure('ไม่พบ user ใน Firebase Authentication');
      }

      // ลบจาก Firebase Auth (ต้องใช้ Admin SDK ใน production)
      // สำหรับ development สามารถใช้ Firebase Console
      print('⚠️ ต้องลบ user จาก Firebase Console:');
      print('1. ไปที่ Firebase Console > Authentication > Users');
      print('2. หา user ที่มี email: $email');
      print('3. กดปุ่ม "Delete user"');

      // ลบจาก Firestore
      for (final user in users) {
        try {
          await _firestore.collection('admins').doc(user.uid).delete();
          print('✅ ลบ admin profile จาก Firestore สำเร็จ: ${user.uid}');
        } catch (e) {
          print('⚠️ ไม่พบ admin profile ใน Firestore: ${user.uid}');
        }
      }

      return AdminManagementResult.success('ลบ admin user สำเร็จ กรุณาลบจาก Firebase Console ด้วย');
    } catch (e) {
      return AdminManagementResult.failure('เกิดข้อผิดพลาด: $e');
    }
  }

  /// ตรวจสอบว่า email มีอยู่ใน Firebase Auth หรือไม่
  static Future<bool> isEmailInUse(String email) async {
    try {
      final users = await _getUsersByEmail(email);
      return users.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  /// หา users จาก email (ใช้ Admin SDK ใน production)
  static Future<List<UserRecord>> _getUsersByEmail(String email) async {
    // ใน production ควรใช้ Admin SDK
    // สำหรับ development ใช้ Firebase Console
    try {
      // ตรวจสอบจาก Firestore แทน
      final snapshot = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .get();
      
      final List<UserRecord> users = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        // สร้าง UserRecord จำลอง
        users.add(UserRecord(
          uid: doc.id,
          email: data['email'],
          displayName: data['name'],
        ));
      }
      
      return users;
    } catch (e) {
      print('Error getting users by email: $e');
      return [];
    }
  }

  /// สร้าง Admin User ใหม่ (เมื่อ Firebase Auth ยังไม่มี user)
  static Future<AdminManagementResult> createAdminUser({
    required String email,
    required String password,
    required String adminName,
    required String adminEmail, // อีเมลของ admin ที่สร้าง
  }) async {
    try {
      // ตรวจสอบสิทธิ์ admin
      if (!_adminEmails.contains(adminEmail.toLowerCase())) {
        return AdminManagementResult.failure('ไม่มีสิทธิ์สร้าง admin user');
      }

      // ตรวจสอบว่า email อยู่ใน whitelist หรือไม่
      if (!_adminEmails.contains(email.toLowerCase())) {
        return AdminManagementResult.failure('อีเมลนี้ไม่มีสิทธิ์เป็น admin');
      }

      // ตรวจสอบว่า email มีอยู่แล้วหรือไม่
      final isEmailExists = await isEmailInUse(email);
      if (isEmailExists) {
        return AdminManagementResult.failure('อีเมลนี้มีอยู่ในระบบแล้ว กรุณาลบจาก Firebase Console ก่อน');
      }

      // สร้าง user ใน Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // อัปเดตข้อมูลผู้ใช้
        await credential.user!.updateDisplayName(adminName);
        
        // บันทึกข้อมูล Admin ใน Firestore
        await _firestore.collection('admins').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'name': adminName,
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'lastLoginAt': FieldValue.serverTimestamp(),
          'createdBy': adminEmail,
        });

        return AdminManagementResult.success('สร้าง admin user สำเร็จ');
      } else {
        return AdminManagementResult.failure('ไม่สามารถสร้าง user ได้');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'อีเมลนี้ถูกใช้งานแล้ว กรุณาลบจาก Firebase Console ก่อน';
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
      return AdminManagementResult.failure(errorMessage);
    } catch (e) {
      return AdminManagementResult.failure('เกิดข้อผิดพลาดที่ไม่คาดคิด: $e');
    }
  }

  /// รับรายการ Admin ทั้งหมด
  static Future<List<AdminUser>> getAllAdmins() async {
    try {
      final snapshot = await _firestore
          .collection('admins')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AdminUser(
          uid: doc.id,
          email: data['email'] ?? '',
          name: data['name'] ?? '',
          isActive: data['isActive'] ?? false,
          createdAt: data['createdAt']?.toDate(),
          lastLoginAt: data['lastLoginAt']?.toDate(),
          createdBy: data['createdBy'],
        );
      }).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('Permission denied: ${e.message}');
        throw Exception('ไม่มีสิทธิ์เข้าถึงข้อมูล admin กรุณาตั้งค่า Firestore Rules');
      }
      print('Firebase error getting admins: $e');
      throw Exception('เกิดข้อผิดพลาดจาก Firebase: ${e.message}');
    } catch (e) {
      print('Error getting admins: $e');
      throw Exception('เกิดข้อผิดพลาดที่ไม่คาดคิด: $e');
    }
  }

  /// อัปเดตสถานะ Admin
  static Future<AdminManagementResult> updateAdminStatus({
    required String uid,
    required bool isActive,
    required String adminEmail,
  }) async {
    try {
      // ตรวจสอบสิทธิ์ admin
      if (!_adminEmails.contains(adminEmail.toLowerCase())) {
        return AdminManagementResult.failure('ไม่มีสิทธิ์อัปเดต admin');
      }

      await _firestore.collection('admins').doc(uid).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return AdminManagementResult.success('อัปเดตสถานะ admin สำเร็จ');
    } catch (e) {
      return AdminManagementResult.failure('เกิดข้อผิดพลาด: $e');
    }
  }

  /// ตรวจสอบสถานะ Admin
  static Future<AdminStatusResult> checkAdminStatus(String email) async {
    try {
      // ตรวจสอบจาก Firestore
      final snapshot = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return AdminStatusResult(
          existsInFirestore: false,
          existsInAuth: false, // ไม่สามารถตรวจสอบได้ใน development
          isActive: false,
        );
      }

      final data = snapshot.docs.first.data();
      return AdminStatusResult(
        existsInFirestore: true,
        existsInAuth: true, // สมมติว่ามี
        isActive: data['isActive'] ?? false,
      );
    } catch (e) {
      return AdminStatusResult(
        existsInFirestore: false,
        existsInAuth: false,
        isActive: false,
      );
    }
  }
}

/// ผลลัพธ์การจัดการ Admin
class AdminManagementResult {
  final bool success;
  final String message;

  AdminManagementResult._(this.success, this.message);

  factory AdminManagementResult.success(String message) => AdminManagementResult._(true, message);
  factory AdminManagementResult.failure(String message) => AdminManagementResult._(false, message);
}

/// สถานะ Admin
class AdminStatusResult {
  final bool existsInFirestore;
  final bool existsInAuth;
  final bool isActive;

  AdminStatusResult({
    required this.existsInFirestore,
    required this.existsInAuth,
    required this.isActive,
  });

  bool get canCreate => !existsInFirestore && !existsInAuth;
  bool get needsCleanup => existsInAuth && !existsInFirestore;
}

/// ข้อมูล Admin User
class AdminUser {
  final String uid;
  final String email;
  final String name;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String? createdBy;

  AdminUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.isActive,
    this.createdAt,
    this.lastLoginAt,
    this.createdBy,
  });
}

/// UserRecord จำลอง
class UserRecord {
  final String uid;
  final String? email;
  final String? displayName;

  UserRecord({
    required this.uid,
    this.email,
    this.displayName,
  });
}
