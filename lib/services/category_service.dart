import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  CategoryService._(); // ป้องกันไม่ให้ new จากข้างนอก
  static final _db = FirebaseFirestore.instance;
  static const _col = 'categories';

  // ================= READ =================

  /// ดึงหมวดหมู่ทั้งหมด (เรียงตามชื่อ) แบบเรียลไทม์
  static Stream<List<Category>> watchCategories() {
    return _db
        .collection(_col)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(Category.fromFirestore).toList());
  }

  /// ดึงเฉพาะหมวดหมู่ที่เปิดใช้งาน (isActive == true)
  /// ใช้เวลาจะแสดงให้ลูกค้าเลือกหมวดที่ขายจริง
  static Stream<List<Category>> watchActiveCategories() {
    return _db
        .collection(_col)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(Category.fromFirestore).toList());
  }

  /// ดึงข้อมูลหมวดหมู่ทีละตัว (ใช้เวลาแก้ไข)
  static Future<Category?> getCategoryById(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    return doc.exists ? Category.fromFirestore(doc) : null;
  }

  // ================= WRITE =================

  /// เพิ่มหมวดหมู่ใหม่
  /// (เช็คไม่ให้ชื่อซ้ำ เพื่อป้องกันหมวด "กระเป๋า" ซ้ำกันหลายอัน)
  static Future<String> addCategory(Category c) async {
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

  /// อัปเดตข้อมูลหมวดหมู่เดิม
  /// (ถ้าจะเปลี่ยนชื่อ ก็ยังป้องกันซ้ำอยู่)
  static Future<void> updateCategory(Category c) async {
    final dup = await _db
        .collection(_col)
        .where('name', isEqualTo: c.name)
        .limit(1)
        .get();

    final hasDupOtherDoc =
        dup.docs.isNotEmpty && dup.docs.first.id != c.id;

    if (hasDupOtherDoc) {
      throw Exception('ชื่อหมวดหมู่นี้มีอยู่แล้ว');
    }

    await _db.collection(_col).doc(c.id).update({
      ...c.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ลบหมวดหมู่
  /// ป้องกันการลบหมวดที่ยังมีสินค้าใช้อยู่
  static Future<void> deleteCategory(String categoryId) async {
    // ตรวจว่ายังมีสินค้าที่ผูกกับหมวดนี้ไหม
    final inUse = await _db
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .limit(1)
        .get();

    if (inUse.docs.isNotEmpty) {
      throw Exception('ลบไม่ได้: ยังมีสินค้าอยู่ในหมวดนี้');
    }

    await _db.collection(_col).doc(categoryId).delete();
  }

  /// เปิด / ปิด หมวดหมู่ (isActive)
  /// ใช้สำหรับซ่อนหมวดชั่วคราว โดยไม่ต้องลบจริง
  static Future<void> toggleCategoryStatus(
      String categoryId, bool isActive) async {
    await _db.collection(_col).doc(categoryId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= (ตัวเลือกเสริม) =================
  // ด้านล่างนี้ "ยังเก็บไว้" ได้ถ้าคุณใช้,
  // แต่ถ้าอยากให้ไฟล์สั้นสุด สามารถย้ายออกไปไฟล์อื่นเป็น util ก็ได้

  /// ค้นหาหมวดหมู่ด้วยชื่อ (ใช้ในหน้าหลังบ้านเวลาพิมพ์ค้นหา)
  static Stream<List<Category>> searchCategories(String query) {
    final q = query.trim();
    if (q.isEmpty) return watchCategories();

    return _db
        .collection(_col)
        .orderBy('name')
        .startAt([q])
        .endAt(['$q\uf8ff'])
        .snapshots()
        .map((snap) => snap.docs.map(Category.fromFirestore).toList());
  }
}
