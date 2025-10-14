import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/brand_model.dart';

class BrandService {
  static final _firestore = FirebaseFirestore.instance;
  static const String _collection = 'brands';

  /// ดึงข้อมูลแบรนด์ทั้งหมด
  static Stream<List<Brand>> watchBrands() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Brand.fromFirestore(doc))
            .toList());
  }

  /// ดึงข้อมูลแบรนด์ที่ใช้งานได้
  static Stream<List<Brand>> watchActiveBrands() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Brand.fromFirestore(doc))
            .toList());
  }

  /// ดึงข้อมูลแบรนด์ตาม ID
  static Future<Brand?> getBrandById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Brand.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('ไม่สามารถดึงข้อมูลแบรนด์ได้: $e');
    }
  }

  /// เพิ่มแบรนด์ใหม่
  static Future<String> addBrand(Brand brand) async {
    try {
      // ตรวจสอบว่าชื่อแบรนด์ซ้ำหรือไม่
      final existingBrand = await _firestore
          .collection(_collection)
          .where('name', isEqualTo: brand.name)
          .limit(1)
          .get();

      if (existingBrand.docs.isNotEmpty) {
        throw Exception('ชื่อแบรนด์นี้มีอยู่แล้ว');
      }

      final docRef = await _firestore
          .collection(_collection)
          .add(brand.toFirestoreForCreate());

      return docRef.id;
    } catch (e) {
      throw Exception('ไม่สามารถเพิ่มแบรนด์ได้: $e');
    }
  }

  /// อัปเดตแบรนด์
  static Future<void> updateBrand(Brand brand) async {
    try {
      // ตรวจสอบว่าชื่อแบรนด์ซ้ำหรือไม่ (ยกเว้นตัวเอง)
      final existingBrand = await _firestore
          .collection(_collection)
          .where('name', isEqualTo: brand.name)
          .limit(1)
          .get();

      if (existingBrand.docs.isNotEmpty && 
          existingBrand.docs.first.id != brand.id) {
        throw Exception('ชื่อแบรนด์นี้มีอยู่แล้ว');
      }

      await _firestore
          .collection(_collection)
          .doc(brand.id)
          .update(brand.toFirestore());
    } catch (e) {
      throw Exception('ไม่สามารถอัปเดตแบรนด์ได้: $e');
    }
  }

  /// ลบแบรนด์
  static Future<void> deleteBrand(String brandId) async {
    try {
      // ตรวจสอบว่ามีสินค้าในแบรนด์นี้หรือไม่
      final products = await _firestore
          .collection('products')
          .where('brand', isEqualTo: await _getBrandNameById(brandId))
          .limit(1)
          .get();

      if (products.docs.isNotEmpty) {
        throw Exception('ไม่สามารถลบแบรนด์นี้ได้ เนื่องจากมีสินค้าอยู่ในแบรนด์นี้');
      }

      await _firestore.collection(_collection).doc(brandId).delete();
    } catch (e) {
      throw Exception('ไม่สามารถลบแบรนด์ได้: $e');
    }
  }

  /// เปลี่ยนสถานะแบรนด์ (เปิด/ปิด)
  static Future<void> toggleBrandStatus(String brandId, bool isActive) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(brandId)
          .update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('ไม่สามารถเปลี่ยนสถานะแบรนด์ได้: $e');
    }
  }

  /// อัปเดตจำนวนสินค้าในแบรนด์
  static Future<void> updateProductCount(String brandId) async {
    try {
      final brand = await getBrandById(brandId);
      if (brand == null) return;

      final products = await _firestore
          .collection('products')
          .where('brand', isEqualTo: brand.name)
          .get();

      await _firestore
          .collection(_collection)
          .doc(brandId)
          .update({
        'productCount': products.docs.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('ไม่สามารถอัปเดตจำนวนสินค้าได้: $e');
    }
  }

  /// อัปเดตจำนวนสินค้าทุกแบรนด์
  static Future<void> updateAllProductCounts() async {
    try {
      final brands = await _firestore.collection(_collection).get();
      
      for (final brandDoc in brands.docs) {
        final brand = Brand.fromFirestore(brandDoc);
        await updateProductCount(brand.id);
      }
    } catch (e) {
      throw Exception('ไม่สามารถอัปเดตจำนวนสินค้าทุกแบรนด์ได้: $e');
    }
  }

  /// ค้นหาแบรนด์
  static Stream<List<Brand>> searchBrands(String query) {
    if (query.isEmpty) {
      return watchBrands();
    }

    return _firestore
        .collection(_collection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Brand.fromFirestore(doc))
            .toList());
  }

  /// ดึงชื่อแบรนด์ตาม ID
  static Future<String> _getBrandNameById(String brandId) async {
    final doc = await _firestore.collection(_collection).doc(brandId).get();
    if (doc.exists) {
      return (doc.data()!['name'] ?? '') as String;
    }
    return '';
  }

  /// สร้างแบรนด์เริ่มต้น
  static Future<void> createDefaultBrands() async {
    try {
      final defaultBrands = [
        {
          'name': 'stylish',
          'description': 'แบรนด์เสื้อผ้าแฟชั่นทันสมัย',
          'isActive': true,
          'productCount': 0,
        },
        {
          'name': 'duex',
          'description': 'แบรนด์เสื้อผ้าแนวสตรีท',
          'isActive': true,
          'productCount': 0,
        },
        {
          'name': 'feelfree',
          'description': 'แบรนด์เสื้อผ้าใส่สบาย',
          'isActive': true,
          'productCount': 0,
        },
        {
          'name': 'unigam',
          'description': 'แบรนด์เสื้อผ้าเกมมิ่ง',
          'isActive': true,
          'productCount': 0,
        },
      ];

      final batch = _firestore.batch();
      
      for (final brandData in defaultBrands) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, {
          ...brandData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('ไม่สามารถสร้างแบรนด์เริ่มต้นได้: $e');
    }
  }
}


