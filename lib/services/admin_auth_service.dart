import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  // Admin email ที่อนุญาต
  static const List<String> _adminEmails = [
    'admin@gmail.com',
    'anucha.suks@gmail.com',
    'yatawikhadi@gmail.com',
    // เพิ่ม admin emails อื่นๆ ที่นี่
  ];

  /// ตรวจสอบว่าผู้ใช้ปัจจุบันเป็น Admin หรือไม่
  static bool get isAdmin {
    final user = _auth.currentUser;
    if (user == null) return false;
    return _adminEmails.contains(user.email?.toLowerCase());
  }

  /// ตรวจสอบว่าผู้ใช้เข้าสู่ระบบแล้วหรือไม่
  static bool get isLoggedIn => _auth.currentUser != null;

  /// รับข้อมูลผู้ใช้ปัจจุบัน
  static User? get currentUser => _auth.currentUser;

  /// รับ UID ของผู้ใช้ปัจจุบัน
  static String? get currentUid => _auth.currentUser?.uid;

  /// รับ Email ของผู้ใช้ปัจจุบัน
  static String? get currentEmail => _auth.currentUser?.email;

  /// เข้าสู่ระบบ Admin
  static Future<AdminAuthResult> signInAdmin({
    required String email,
    required String password,
  }) async {
    try {
      // ตรวจสอบว่าเป็น admin email หรือไม่
      if (!_adminEmails.contains(email.toLowerCase())) {
        return AdminAuthResult.failure('อีเมลนี้ไม่มีสิทธิ์เข้าถึงระบบ Admin');
      }

      // เข้าสู่ระบบ
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // บันทึกข้อมูลการเข้าสู่ระบบ
        await _recordAdminLogin(credential.user!);
        
        return AdminAuthResult.success();
      } else {
        return AdminAuthResult.failure('ไม่สามารถเข้าสู่ระบบได้');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'ไม่พบผู้ใช้นี้ในระบบ';
          break;
        case 'wrong-password':
          errorMessage = 'รหัสผ่านไม่ถูกต้อง';
          break;
        case 'invalid-email':
          errorMessage = 'รูปแบบอีเมลไม่ถูกต้อง';
          break;
        case 'user-disabled':
          errorMessage = 'บัญชีนี้ถูกปิดใช้งาน';
          break;
        case 'too-many-requests':
          errorMessage = 'พยายามเข้าสู่ระบบมากเกินไป กรุณารอสักครู่';
          break;
        default:
          errorMessage = 'เกิดข้อผิดพลาด: ${e.message}';
      }
      return AdminAuthResult.failure(errorMessage);
    } catch (e) {
      return AdminAuthResult.failure('เกิดข้อผิดพลาดที่ไม่คาดคิด: $e');
    }
  }

  /// สมัครสมาชิก Admin (สำหรับ Admin ใหม่)
  static Future<AdminAuthResult> signUpAdmin({
    required String email,
    required String password,
    required String adminName,
  }) async {
    try {
      // ตรวจสอบว่าเป็น admin email หรือไม่
      if (!_adminEmails.contains(email.toLowerCase())) {
        return AdminAuthResult.failure('อีเมลนี้ไม่มีสิทธิ์สมัครเป็น Admin');
      }

      // สมัครสมาชิก
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // อัปเดตข้อมูลผู้ใช้
        await credential.user!.updateDisplayName(adminName);
        
        // บันทึกข้อมูล Admin ใน Firestore
        await _createAdminProfile(credential.user!, adminName);
        
        return AdminAuthResult.success();
      } else {
        return AdminAuthResult.failure('ไม่สามารถสมัครสมาชิกได้');
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
      return AdminAuthResult.failure(errorMessage);
    } catch (e) {
      return AdminAuthResult.failure('เกิดข้อผิดพลาดที่ไม่คาดคิด: $e');
    }
  }

  /// ออกจากระบบ
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// เปลี่ยนรหัสผ่าน
  static Future<AdminAuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AdminAuthResult.failure('ไม่ได้เข้าสู่ระบบ');
      }

      // ตรวจสอบรหัสผ่านปัจจุบัน
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return AdminAuthResult.success();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'รหัสผ่านปัจจุบันไม่ถูกต้อง';
          break;
        case 'weak-password':
          errorMessage = 'รหัสผ่านใหม่ไม่แข็งแรงพอ';
          break;
        default:
          errorMessage = 'เกิดข้อผิดพลาด: ${e.message}';
      }
      return AdminAuthResult.failure(errorMessage);
    } catch (e) {
      return AdminAuthResult.failure('เกิดข้อผิดพลาดที่ไม่คาดคิด: $e');
    }
  }

  /// ส่งอีเมลรีเซ็ตรหัสผ่าน
  static Future<AdminAuthResult> resetPassword(String email) async {
    try {
      // ตรวจสอบว่าเป็น admin email หรือไม่
      if (!_adminEmails.contains(email.toLowerCase())) {
        return AdminAuthResult.failure('อีเมลนี้ไม่มีสิทธิ์เข้าถึงระบบ Admin');
      }

      await _auth.sendPasswordResetEmail(email: email);
      return AdminAuthResult.success();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'ไม่พบผู้ใช้นี้ในระบบ';
          break;
        case 'invalid-email':
          errorMessage = 'รูปแบบอีเมลไม่ถูกต้อง';
          break;
        default:
          errorMessage = 'เกิดข้อผิดพลาด: ${e.message}';
      }
      return AdminAuthResult.failure(errorMessage);
    } catch (e) {
      return AdminAuthResult.failure('เกิดข้อผิดพลาดที่ไม่คาดคิด: $e');
    }
  }

  /// สร้างโปรไฟล์ Admin ใน Firestore
  static Future<void> _createAdminProfile(User user, String adminName) async {
    await _firestore.collection('admins').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'name': adminName,
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  /// บันทึกการเข้าสู่ระบบ
  static Future<void> _recordAdminLogin(User user) async {
    await _firestore.collection('admins').doc(user.uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// รับข้อมูล Admin Profile
  static Future<Map<String, dynamic>?> getAdminProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('admins').doc(user.uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      return null;
    }
  }

  /// ตรวจสอบสิทธิ์ Admin แบบละเอียด
  static Future<bool> hasAdminPermission() async {
    if (!isLoggedIn || !isAdmin) return false;
    
    try {
      final profile = await getAdminProfile();
      return profile != null && profile['isActive'] == true;
    } catch (e) {
      return false;
    }
  }
}

/// ผลลัพธ์การเข้าสู่ระบบ
class AdminAuthResult {
  final bool success;
  final String? errorMessage;

  AdminAuthResult._(this.success, this.errorMessage);

  factory AdminAuthResult.success() => AdminAuthResult._(true, null);
  factory AdminAuthResult.failure(String message) => AdminAuthResult._(false, message);
}

/// สิทธิ์ของผู้ใช้
enum UserRole {
  user,   // ผู้ใช้ทั่วไป
  admin,  // ผู้ดูแลระบบ
}

/// ข้อมูลผู้ใช้
class UserProfile {
  final String uid;
  final String email;
  final String? name;
  final UserRole role;
  final bool isActive;
  final DateTime? lastLoginAt;

  UserProfile({
    required this.uid,
    required this.email,
    this.name,
    required this.role,
    required this.isActive,
    this.lastLoginAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.user,
      isActive: map['isActive'] ?? false,
      lastLoginAt: map['lastLoginAt']?.toDate(),
    );
  }

  bool get isAdmin => role == UserRole.admin;
}

