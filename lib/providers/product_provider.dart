import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _selectedBrand = '';
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  String get selectedBrand => _selectedBrand;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ฟิลเตอร์แบรนด์ที่มีอยู่
  static const List<String> availableBrands = [
    'See All',
    'stylish',
    'duex',
    'feelfree',
    'unigam'
  ];

  /// โหลดสินค้าทั้งหมดจาก Firebase พร้อมข้อมูลแบรนด์และหมวดหมู่
  Future<void> loadProducts() async {
    _setLoading(true);
    _error = null;

    try {
      // ใช้ getProducts แทน watchProductsWithDetails เพื่อรอข้อมูลโหลดเสร็จ
      final productsData = await FirestoreService.getProductsWithDetails();
      _products = productsData;
      print('Debug ProductProvider - Loaded ${_products.length} products');
      
      // Debug: แสดงข้อมูลสินค้าทั้งหมด
      for (var product in _products) {
        print('Debug ProductProvider - Product: ${product.name}');
        print('Debug ProductProvider - Product brandId: ${product.brandId}');
        print('Debug ProductProvider - Product brand: ${product.brand}');
      }
      
      _applyFilter();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      print('Debug ProductProvider - Error loading products: $e');
      _setLoading(false);
    }
  }

  /// ฟิลเตอร์สินค้าตามแบรนด์ (รองรับทั้ง brandId และ brandName)
  void filterByBrand(String brand) {
    print('Debug ProductProvider - filterByBrand: $brand');
    print('Debug ProductProvider - Before setting _selectedBrand: $_selectedBrand');
    _selectedBrand = brand;
    print('Debug ProductProvider - After setting _selectedBrand: $_selectedBrand');
    print('Debug ProductProvider - About to call _applyFilter');
    _applyFilter();
    print('Debug ProductProvider - After calling _applyFilter');
  }

  /// ค้นหาสินค้าตามชื่อ
  void searchProducts(String query) {
    if (query.isEmpty) {
      _applyFilter();
      return;
    }

    _filteredProducts = _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
             product.brand.toLowerCase().contains(query.toLowerCase());
    }).toList();
    notifyListeners();
  }

  /// ใช้ฟิลเตอร์ปัจจุบันกับรายการสินค้า
  void _applyFilter() {
    print('=== Debug _applyFilter START ===');
    print('Debug _applyFilter - Selected Brand: "$_selectedBrand"');
    print('Debug _applyFilter - Selected Brand length: ${_selectedBrand.length}');
    print('Debug _applyFilter - Total Products: ${_products.length}');
    
    if (_selectedBrand.isEmpty || _selectedBrand == 'See All') {
      _filteredProducts = List.from(_products);
      print('Debug _applyFilter - Show all products: ${_filteredProducts.length}');
    } else {
      print('Debug _applyFilter - Filtering by brand: "$_selectedBrand"');
      _filteredProducts = _products.where((product) {
        // ตรวจสอบทั้ง brandId และ brandName
        final matchBrandId = product.brandId.toLowerCase() == _selectedBrand.toLowerCase();
        final matchBrandName = product.brand.toLowerCase() == _selectedBrand.toLowerCase();
        
        // ตรวจสอบ brandName ที่ได้จาก brandId (ถ้ามี)
        final matchBrandNameFromId = product.brandName != null && 
            product.brandName!.toLowerCase() == _selectedBrand.toLowerCase();
        
        print('Debug _applyFilter - Product: "${product.name}"');
        print('Debug _applyFilter - Product brandId: "${product.brandId}"');
        print('Debug _applyFilter - Product brand: "${product.brand}"');
        print('Debug _applyFilter - Product brandName: "${product.brandName}"');
        print('Debug _applyFilter - Selected Brand: "$_selectedBrand"');
        print('Debug _applyFilter - Match brandId: $matchBrandId');
        print('Debug _applyFilter - Match brandName: $matchBrandName');
        print('Debug _applyFilter - Match brandNameFromId: $matchBrandNameFromId');
        print('Debug _applyFilter - Final match: ${matchBrandId || matchBrandName || matchBrandNameFromId}');
        
        return matchBrandId || matchBrandName || matchBrandNameFromId;
      }).toList();
      print('Debug _applyFilter - Filtered products: ${_filteredProducts.length}');
    }
    print('=== Debug _applyFilter END ===');
    notifyListeners();
  }

 
  /// ดึงสินค้าตามหมวดหมู่เฉพาะ
  List<Product> getProductsByCategory(String categoryId) {
    return _products.where((product) {
      return product.categoryId.toLowerCase() == categoryId.toLowerCase();
    }).toList();
  }



  /// ลบสินค้า
  Future<void> deleteProduct(String productId) async {
    try {
      await FirestoreService.deleteProduct(productId);
      // อัปเดตรายการสินค้า
      _products.removeWhere((product) => product.id == productId);
      _applyFilter();
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
}

