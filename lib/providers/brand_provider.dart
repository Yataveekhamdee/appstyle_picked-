import 'package:flutter/foundation.dart';
import '../models/brand_model.dart';
import '../services/brand_service.dart';

class BrandProvider extends ChangeNotifier {
  List<Brand> _brands = [];
  bool _isLoading = false;
  String? _error;

  List<Brand> get brands => _brands;
  List<Brand> get activeBrands => _brands.where((brand) => brand.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// โหลดข้อมูลแบรนด์ทั้งหมดจาก Firebase
  Future<void> loadBrands() async {
    _setLoading(true);
    _error = null;

    try {
      final brandsStream = BrandService.watchBrands();
      
      brandsStream.listen((brandsData) {
        _brands = brandsData;
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

  /// ดึงข้อมูลแบรนด์ตาม ID
  Brand? getBrandById(String brandId) {
    try {
      return _brands.firstWhere((brand) => brand.id == brandId);
    } catch (e) {
      return null;
    }
  }

  /// ดึงชื่อแบรนด์ตาม ID
  String getBrandNameById(String brandId) {
    final brand = getBrandById(brandId);
    return brand?.name ?? brandId; // ถ้าไม่พบจะคืนค่า brandId
  }

  /// ค้นหาแบรนด์ตามชื่อ
  List<Brand> searchBrands(String query) {
    if (query.isEmpty) return _brands;
    
    return _brands.where((brand) {
      return brand.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// ดึงแบรนด์ที่เปิดใช้งานเท่านั้น
  List<Brand> getActiveBrands() {
    return _brands.where((brand) => brand.isActive).toList();
  }

  /// ดึงแบรนด์ที่ปิดใช้งาน
  List<Brand> getInactiveBrands() {
    return _brands.where((brand) => !brand.isActive).toList();
  }

  /// เพิ่มแบรนด์ใหม่
  Future<void> addBrand(Brand brand) async {
    try {
      await BrandService.addBrand(brand);
      // ไม่ต้องโหลดใหม่ เพราะ Stream จะอัปเดตให้อัตโนมัติ
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// อัปเดตแบรนด์
  Future<void> updateBrand(Brand brand) async {
    try {
      await BrandService.updateBrand(brand);
      // ไม่ต้องโหลดใหม่ เพราะ Stream จะอัปเดตให้อัตโนมัติ
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// ลบแบรนด์
  Future<void> deleteBrand(String brandId) async {
    try {
      await BrandService.deleteBrand(brandId);
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
