import 'package:flutter/foundation.dart';
import '../models/category_model.dart' as category_model;
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  // --- state หลักที่ UI ต้องใช้ ---
  List<category_model.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  // --- ให้หน้า UI ดึงข้อมูลได้ผ่าน getter ---
  List<category_model.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // หมวดหมู่ที่เปิดใช้งาน (isActive = true)
  // ใช้โชว์ปุ่ม ChoiceChip / Dropdown หมวดหมู่สินค้า
  List<category_model.Category> get activeCategories =>
      _categories.where((c) => c.isActive).toList();

  // โหลดหมวดหมู่ทั้งหมดจาก Firebase แบบ realtime
  // อธิบายง่าย ๆ: ฟัง Stream จาก CategoryService
  Future<void> loadCategories() async {
    _setLoading(true);
    _error = null;

    try {
      final stream = CategoryService.watchCategories();

      // listen = ถ้ามีการเปลี่ยนแปลงที่ Firebase จะอัปเดตอัตโนมัติ
      stream.listen((data) {
        _categories = data;
        _setLoading(false);
      }, onError: (err) {
        _error = err.toString();
        _setLoading(false);
      });
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // หาหมวดหมู่จาก id (ถ้าไม่เจอ ให้ null)
  category_model.Category? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  // สำหรับเวลาต้องการชื่อหมวดหมู่ไปแสดงในสินค้า
  // ถ้าไม่เจอ id จะคืน id เองแทนเพื่อไม่ให้แอปพัง
  String getCategoryNameById(String categoryId) {
    final c = getCategoryById(categoryId);
    return c?.name ?? categoryId;
  }

  // ค้นหาหมวดหมู่ด้วยข้อความ (ใช้กับช่องค้นหา ถ้ามี)
  List<category_model.Category> searchCategories(String query) {
    if (query.isEmpty) return _categories;
    final q = query.toLowerCase();
    return _categories.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  // เพิ่มหมวดหมู่ใหม่ (เรียกใช้จากหน้าหลังบ้าน / แอดมิน)
  Future<void> addCategory(category_model.Category category) async {
    try {
      await CategoryService.addCategory(category);
      // ไม่ต้อง setState เอง เพราะ loadCategories() ฟัง Stream อยู่แล้ว
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // แก้ไขหมวดหมู่
  Future<void> updateCategory(category_model.Category category) async {
    try {
      await CategoryService.updateCategory(category);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ลบหมวดหมู่
  Future<void> deleteCategory(String categoryId) async {
    try {
      await CategoryService.deleteCategory(categoryId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ใช้ภายในคลาสนี้ เพื่ออัปเดตสถานะโหลด แล้วแจ้ง UI ให้รีเฟรช
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
