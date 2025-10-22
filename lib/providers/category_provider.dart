import 'package:flutter/foundation.dart';
import '../models/category_model.dart' as category_model;
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<category_model.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<category_model.Category> get categories => _categories;
  List<category_model.Category> get activeCategories => _categories.where((category) => category.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// โหลดข้อมูลหมวดหมู่ทั้งหมดจาก Firebase
  Future<void> loadCategories() async {
    _setLoading(true);
    _error = null;

    try {
      final categoriesStream = CategoryService.watchCategories();
      
      categoriesStream.listen((categoriesData) {
        _categories = categoriesData;
        _setLoading(false);
      }, onError: (error) {
        _error = error.toString();
        _setLoading(false);
      });
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  /// ดึงข้อมูลหมวดหมู่ตาม ID
  category_model.Category? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// ดึงชื่อหมวดหมู่ตาม ID
  String getCategoryNameById(String categoryId) {
    final category = getCategoryById(categoryId);
    return category?.name ?? categoryId; // ถ้าไม่พบจะคืนค่า categoryId
  }

  /// ค้นหาหมวดหมู่ตามชื่อ
  List<category_model.Category> searchCategories(String query) {
    if (query.isEmpty) return _categories;
    
    return _categories.where((category) {
      return category.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// ดึงหมวดหมู่ที่เปิดใช้งานเท่านั้น
  List<category_model.Category> getActiveCategories() {
    return _categories.where((category) => category.isActive).toList();
  }

  /// ดึงหมวดหมู่ที่ปิดใช้งาน
  List<category_model.Category> getInactiveCategories() {
    return _categories.where((category) => !category.isActive).toList();
  }

  /// เพิ่มหมวดหมู่ใหม่
  Future<void> addCategory(category_model.Category category) async {
    try {
      await CategoryService.addCategory(category);
      // ไม่ต้องโหลดใหม่ เพราะ Stream จะอัปเดตให้อัตโนมัติ
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// อัปเดตหมวดหมู่
  Future<void> updateCategory(category_model.Category category) async {
    try {
      await CategoryService.updateCategory(category);
      // ไม่ต้องโหลดใหม่ เพราะ Stream จะอัปเดตให้อัตโนมัติ
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// ลบหมวดหมู่
  Future<void> deleteCategory(String categoryId) async {
    try {
      await CategoryService.deleteCategory(categoryId);
      // ไม่ต้องโหลดใหม่ เพราะ Stream จะอัปเดตให้อัตโนมัติ
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}