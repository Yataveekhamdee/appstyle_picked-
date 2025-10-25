import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class ProductProvider extends ChangeNotifier {
  // --- state หลักของสินค้า ---
  List<Product> _products = [];         // สินค้าทั้งหมดจาก Firebase
  List<Product> _filteredProducts = []; // สินค้าที่ถูกกรองแล้ว (เช่นตามแบรนด์ / ค้นหา)
  String _selectedBrand = '';           // แบรนด์ที่ถูกเลือกตอนนี้
  bool _isLoading = false;              // ใช้โชว์วงกลมโหลด
  String? _error;                       // เก็บข้อความ error ถ้าโหลดพัง

  // getter ให้หน้า UI เรียกใช้
  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  String get selectedBrand => _selectedBrand;
  bool get isLoading => _isLoading;
  String? get error => _error;


  // โหลดสินค้าจาก Firebase (เรียกตอนเข้าแอป/เข้าเพจสินค้า)
  Future<void> loadProducts() async {
    _setLoading(true);
    _error = null;

    try {
      // ดึงสินค้าพร้อมข้อมูลแบรนด์และหมวดหมู่ที่ join มาแล้ว
      final productsData = await FirestoreService.getProductsWithDetails();
      _products = productsData;

      // เริ่มต้นให้รายการที่โชว์ = ทั้งหมด
      _applyFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ใช้ฟิลเตอร์แบรนด์ปัจจุบัน (_selectedBrand) มากรองรายการ
  void _applyFilter() {
    if (_selectedBrand.isEmpty || _selectedBrand == 'See All') {
      _filteredProducts = List.from(_products);
    } else {
      final b = _selectedBrand.toLowerCase();
      _filteredProducts = _products.where((p) {
        final byId    = p.brandId.toLowerCase() == b;
        final byName  = p.brand.toLowerCase() == b;
        final byLabel = (p.brandName ?? '').toLowerCase() == b;
        return byId || byName || byLabel;
      }).toList();
    }

    notifyListeners();
  }

  // ดึงสินค้าเฉพาะหมวดหมู่ (ถ้าอยากใช้หน้า "สินค้าหมวดหมู่นี้")
  List<Product> getProductsByCategory(String categoryId) {
    final id = categoryId.toLowerCase();
    return _products.where((p) => p.categoryId.toLowerCase() == id).toList();
  }

  // ลบสินค้า (ใช้ในหลังบ้าน / แอดมิน)
  Future<void> deleteProduct(String productId) async {
    try {
      await FirestoreService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      _applyFilter(); // อัปเดตของที่โชว์หลังลบ
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // อัปเดตสถานะโหลด แล้วแจ้ง UI ให้รีเฟรช
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
