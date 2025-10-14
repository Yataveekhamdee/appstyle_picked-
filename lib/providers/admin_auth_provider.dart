import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/admin_auth_service.dart';

class AdminAuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAdmin = false;
  bool _isLoading = true;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminAuthProvider() {
    _initialize();
  }

  /// เริ่มต้น Auth Provider
  Future<void> _initialize() async {
    _setLoading(true);
    
    try {
      // ตรวจสอบสถานะการเข้าสู่ระบบ
      _currentUser = FirebaseAuth.instance.currentUser;
      
      if (_currentUser != null) {
        // ตรวจสอบสิทธิ์ Admin
        _isAdmin = AdminAuthService.isAdmin;
        
        // ตรวจสอบสิทธิ์แบบละเอียด
        if (_isAdmin) {
          _isAdmin = await AdminAuthService.hasAdminPermission();
        }
      } else {
        _isAdmin = false;
      }
    } catch (e) {
      _error = e.toString();
      _isAdmin = false;
    } finally {
      _setLoading(false);
    }

    // ฟังการเปลี่ยนแปลงสถานะ Auth
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  /// จัดการการเปลี่ยนแปลงสถานะ Auth
  Future<void> _onAuthStateChanged(User? user) async {
    _currentUser = user;
    
    if (user != null) {
      // ตรวจสอบสิทธิ์ Admin
      _isAdmin = AdminAuthService.isAdmin;
      
      if (_isAdmin) {
        _isAdmin = await AdminAuthService.hasAdminPermission();
      }
    } else {
      _isAdmin = false;
    }
    
    notifyListeners();
  }

  /// เข้าสู่ระบบ Admin
  Future<AdminAuthResult> signInAdmin({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AdminAuthService.signInAdmin(
        email: email,
        password: password,
      );

      if (result.success) {
        _currentUser = FirebaseAuth.instance.currentUser;
        _isAdmin = await AdminAuthService.hasAdminPermission();
      } else {
        _error = result.errorMessage;
      }

      return result;
    } catch (e) {
      _error = e.toString();
      return AdminAuthResult.failure(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// สมัครสมาชิก Admin
  Future<AdminAuthResult> signUpAdmin({
    required String email,
    required String password,
    required String adminName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AdminAuthService.signUpAdmin(
        email: email,
        password: password,
        adminName: adminName,
      );

      if (result.success) {
        _currentUser = FirebaseAuth.instance.currentUser;
        _isAdmin = await AdminAuthService.hasAdminPermission();
      } else {
        _error = result.errorMessage;
      }

      return result;
    } catch (e) {
      _error = e.toString();
      return AdminAuthResult.failure(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// ออกจากระบบ
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await AdminAuthService.signOut();
      _currentUser = null;
      _isAdmin = false;
      _clearError();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// เปลี่ยนรหัสผ่าน
  Future<AdminAuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AdminAuthService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!result.success) {
        _error = result.errorMessage;
      }

      return result;
    } catch (e) {
      _error = e.toString();
      return AdminAuthResult.failure(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// ส่งอีเมลรีเซ็ตรหัสผ่าน
  Future<AdminAuthResult> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AdminAuthService.resetPassword(email);
      
      if (!result.success) {
        _error = result.errorMessage;
      }

      return result;
    } catch (e) {
      _error = e.toString();
      return AdminAuthResult.failure(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// รีเฟรชข้อมูล Auth
  Future<void> refreshAuth() async {
    _setLoading(true);
    
    try {
      await _currentUser?.reload();
      _currentUser = FirebaseAuth.instance.currentUser;
      
      if (_currentUser != null) {
        _isAdmin = AdminAuthService.isAdmin;
        
        if (_isAdmin) {
          _isAdmin = await AdminAuthService.hasAdminPermission();
        }
      } else {
        _isAdmin = false;
      }
      
      _clearError();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// ตรวจสอบสิทธิ์ Admin แบบละเอียด
  Future<bool> checkAdminPermission() async {
    try {
      _isAdmin = await AdminAuthService.hasAdminPermission();
      notifyListeners();
      return _isAdmin;
    } catch (e) {
      _error = e.toString();
      _isAdmin = false;
      notifyListeners();
      return false;
    }
  }

  /// รับข้อมูล Admin Profile
  Future<Map<String, dynamic>?> getAdminProfile() async {
    try {
      return await AdminAuthService.getAdminProfile();
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}

