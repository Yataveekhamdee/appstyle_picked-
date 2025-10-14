import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  static final _firestore = FirebaseFirestore.instance;
  static const String _collection = 'categories';

  /// ดึงข้อมูลหมวดหมู่ทั้งหมด
  static Stream<List<Category>> watchCategories() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromFirestore(doc))
            .toList());
  }

  /// ดึงข้อมูลหมวดหมู่ที่ใช้งานได้
  static Stream<List<Category>> watchActiveCategories() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromFirestore(doc))
            .toList());
  }

  /// ดึงข้อมูลหมวดหมู่ตาม ID
  static Future<Category?> getCategoryById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Category.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('ไม่สามารถดึงข้อมูลหมวดหมู่ได้: $e');
    }
  }

  /// เพิ่มหมวดหมู่ใหม่
  static Future<String> addCategory(Category category) async {
    try {
      // ตรวจสอบว่าชื่อหมวดหมู่ซ้ำหรือไม่
      final existingCategory = await _firestore
          .collection(_collection)
          .where('name', isEqualTo: category.name)
          .limit(1)
          .get();

      if (existingCategory.docs.isNotEmpty) {
        throw Exception('ชื่อหมวดหมู่นี้มีอยู่แล้ว');
      }

      final docRef = await _firestore
          .collection(_collection)
          .add(category.toFirestoreForCreate());

      return docRef.id;
    } catch (e) {
      throw Exception('ไม่สามารถเพิ่มหมวดหมู่ได้: $e');
    }
  }

  /// อัปเดตหมวดหมู่
  static Future<void> updateCategory(Category category) async {
    try {
      // ตรวจสอบว่าชื่อหมวดหมู่ซ้ำหรือไม่ (ยกเว้นตัวเอง)
      final existingCategory = await _firestore
          .collection(_collection)
          .where('name', isEqualTo: category.name)
          .limit(1)
          .get();

      if (existingCategory.docs.isNotEmpty && 
          existingCategory.docs.first.id != category.id) {
        throw Exception('ชื่อหมวดหมู่นี้มีอยู่แล้ว');
      }

      await _firestore
          .collection(_collection)
          .doc(category.id)
          .update(category.toFirestore());
    } catch (e) {
      throw Exception('ไม่สามารถอัปเดตหมวดหมู่ได้: $e');
    }
  }

  /// ลบหมวดหมู่
  static Future<void> deleteCategory(String categoryId) async {
    try {
      // ตรวจสอบว่ามีสินค้าในหมวดหมู่นี้หรือไม่
      final products = await _firestore
          .collection('products')
          .where('category', isEqualTo: await _getCategoryNameById(categoryId))
          .limit(1)
          .get();

      if (products.docs.isNotEmpty) {
        throw Exception('ไม่สามารถลบหมวดหมู่นี้ได้ เนื่องจากมีสินค้าอยู่ในหมวดหมู่นี้');
      }

      await _firestore.collection(_collection).doc(categoryId).delete();
    } catch (e) {
      throw Exception('ไม่สามารถลบหมวดหมู่ได้: $e');
    }
  }

  /// เปลี่ยนสถานะหมวดหมู่ (เปิด/ปิด)
  static Future<void> toggleCategoryStatus(String categoryId, bool isActive) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(categoryId)
          .update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('ไม่สามารถเปลี่ยนสถานะหมวดหมู่ได้: $e');
    }
  }

  /// อัปเดตจำนวนสินค้าในหมวดหมู่
  static Future<void> updateProductCount(String categoryId) async {
    try {
      final category = await getCategoryById(categoryId);
      if (category == null) return;

      final products = await _firestore
          .collection('products')
          .where('category', isEqualTo: category.name)
          .get();

      await _firestore
          .collection(_collection)
          .doc(categoryId)
          .update({
        'productCount': products.docs.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('ไม่สามารถอัปเดตจำนวนสินค้าได้: $e');
    }
  }

  /// อัปเดตจำนวนสินค้าทุกหมวดหมู่
  static Future<void> updateAllProductCounts() async {
    try {
      final categories = await _firestore.collection(_collection).get();
      
      for (final categoryDoc in categories.docs) {
        final category = Category.fromFirestore(categoryDoc);
        await updateProductCount(category.id);
      }
    } catch (e) {
      throw Exception('ไม่สามารถอัปเดตจำนวนสินค้าทุกหมวดหมู่ได้: $e');
    }
  }

  /// ค้นหาหมวดหมู่
  static Stream<List<Category>> searchCategories(String query) {
    if (query.isEmpty) {
      return watchCategories();
    }

    return _firestore
        .collection(_collection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromFirestore(doc))
            .toList());
  }

  /// ดึงชื่อหมวดหมู่ตาม ID
  static Future<String> _getCategoryNameById(String categoryId) async {
    final doc = await _firestore.collection(_collection).doc(categoryId).get();
    if (doc.exists) {
      return (doc.data()!['name'] ?? '') as String;
    }
    return '';
  }

  /// สร้างหมวดหมู่เริ่มต้น
  static Future<void> createDefaultCategories() async {
    try {
      final defaultCategories = [
        {
          'name': 'เสื้อผ้า',
          'description': 'เสื้อผ้าทุกประเภท',
          'isActive': true,
          'productCount': 0,
        },
        {
          'name': 'กระเป๋า',
          'description': 'กระเป๋าทุกประเภท',
          'isActive': true,
          'productCount': 0,
        },
        {
          'name': 'รองเท้า',
          'description': 'รองเท้าทุกประเภท',
          'isActive': true,
          'productCount': 0,
        },
        {
          'name': 'เครื่องประดับ',
          'description': 'เครื่องประดับทุกประเภท',
          'isActive': true,
          'productCount': 0,
        },
        {
          'name': 'แว่นตา',
          'description': 'แว่นตาและแว่นกันแดด',
          'isActive': true,
          'productCount': 0,
        },
      ];

      final batch = _firestore.batch();
      
      for (final categoryData in defaultCategories) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, {
          ...categoryData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('ไม่สามารถสร้างหมวดหมู่เริ่มต้นได้: $e');
    }
  }
}


