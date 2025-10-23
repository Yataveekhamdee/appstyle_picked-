import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  CategoryService._();
  static final _db = FirebaseFirestore.instance;
  static const _col = 'categories';

  // ========== READ ==========
  /// ดูหมวดหมู่ทั้งหมด (เรียงตามชื่อ)
  static Stream<List<Category>> watchCategories() {
    return _db.collection(_col).orderBy('name').snapshots().map(
      (s) => s.docs.map(Category.fromFirestore).toList(),
    );
  }

  /// ดูเฉพาะหมวดที่เปิดใช้งาน
  static Stream<List<Category>> watchActiveCategories() {
    return _db
        .collection(_col)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map(Category.fromFirestore).toList());
  }

  /// ดึงหมวดหมู่รายตัว
  static Future<Category?> getCategoryById(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    return doc.exists ? Category.fromFirestore(doc) : null;
  }

  // ========== WRITE ==========
  /// เพิ่มหมวดหมู่ (กันชื่อซ้ำ)
  static Future<String> addCategory(Category c) async {
    // กันชื่อซ้ำด้วย field name
    final dup = await _db
        .collection(_col)
        .where('name', isEqualTo: c.name)
        .limit(1)
        .get();
    if (dup.docs.isNotEmpty) {
      throw Exception('ชื่อหมวดหมู่นี้มีอยู่แล้ว');
    }

    final ref = await _db.collection(_col).add({
      ...c.toFirestoreForCreate(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// แก้ไขหมวดหมู่ (กันชื่อซ้ำ โดยยกเว้นตัวเอง)
  static Future<void> updateCategory(Category c) async {
    final dup = await _db
        .collection(_col)
        .where('name', isEqualTo: c.name)
        .limit(1)
        .get();

    if (dup.docs.isNotEmpty && dup.docs.first.id != c.id) {
      throw Exception('ชื่อหมวดหมู่นี้มีอยู่แล้ว');
    }

    await _db.collection(_col).doc(c.id).update({
      ...c.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ลบหมวดหมู่ (ห้ามลบถ้ายังมีสินค้าอ้างอิง)
  /// ✅ เช็คด้วย categoryId โดยตรง — ง่ายและแม่นสุด
  static Future<void> deleteCategory(String categoryId) async {
    final productUsing = await _db
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .limit(1)
        .get();
    if (productUsing.docs.isNotEmpty) {
      throw Exception('ลบไม่ได้: ยังมีสินค้าอยู่ในหมวดนี้');
    }
    await _db.collection(_col).doc(categoryId).delete();
  }

  /// เปิด/ปิดการใช้งานหมวด
  static Future<void> toggleCategoryStatus(String categoryId, bool isActive) {
    return _db.collection(_col).doc(categoryId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ========== UTILITIES ==========
  /// อัปเดตตัวเลขจำนวนสินค้าในหมวด (นับจาก products ที่ผูกด้วย categoryId)
  static Future<void> updateProductCount(String categoryId) async {
    final total = await _db
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .count()
        .get(); // ใช้ aggregation API (ถ้ารองรับ) หรือเปลี่ยนเป็น get().then((q)=>q.docs.length)

    await _db.collection(_col).doc(categoryId).update({
      'productCount': total.count, // ถ้าโปรเจ็กต์ยังไม่รองรับ .count() ให้ใช้ q.docs.length แทน
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// อัปเดตจำนวนสินค้าทุกหมวด (เรียกทีเดียวตอน sync)
  static Future<void> updateAllProductCounts() async {
    final cats = await _db.collection(_col).get();
    for (final d in cats.docs) {
      await updateProductCount(d.id);
    }
  }

  /// ค้นหาหมวดด้วยชื่อ (prefix)
  static Stream<List<Category>> searchCategories(String query) {
    final q = query.trim();
    if (q.isEmpty) return watchCategories();
    return _db
        .collection(_col)
        .orderBy('name')
        .startAt([q]).endAt(['$q\uf8ff'])
        .snapshots()
        .map((s) => s.docs.map(Category.fromFirestore).toList());
  }

  /// สร้างหมวดเริ่มต้น (ใช้ครั้งแรก/ทดสอบ)
  static Future<void> createDefaultCategories() async {
    final defaults = [
      {'name': 'เสื้อผ้า', 'description': 'เสื้อผ้าทุกประเภท'},
      {'name': 'กระเป๋า', 'description': 'กระเป๋าทุกประเภท'},
      {'name': 'รองเท้า', 'description': 'รองเท้าทุกประเภท'},
      {'name': 'เครื่องประดับ', 'description': 'เครื่องประดับทุกประเภท'},
      {'name': 'แว่นตา', 'description': 'แว่นตาและแว่นกันแดด'},
    ];

    final batch = _db.batch();
    for (final m in defaults) {
      final ref = _db.collection(_col).doc();
      batch.set(ref, {
        ...m,
        'isActive': true,
        'productCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
