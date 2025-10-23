import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirestoreService {
  FirestoreService._();
  static final _db = FirebaseFirestore.instance;

  // ----- helpers -----
  static FieldValue get _now => FieldValue.serverTimestamp();
  static String _shortOrderId() {
    final s = DateTime.now().millisecondsSinceEpoch.toString();
    return 'ORD-${s.substring(s.length - 6)}';
  }

  // ========== PRODUCTS ==========

  /// สตรีมรายการสินค้า (ใส่ filter ได้เล็กน้อยถ้าต้องการ)
  static Stream<List<Map<String, dynamic>>> watchProducts({
    String? brand,
    String? category,
  }) {
    Query<Map<String, dynamic>> q = _db.collection('products');
    if (brand != null && brand.isNotEmpty) {
      q = q.where('brand', isEqualTo: brand);
    }
    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    return q.orderBy('updatedAt', descending: true).snapshots().map(
      (s) => s.docs.map((d) {
        final m = d.data();
        return {
          'id'         : d.id,
          'name'       : (m['name'] ?? '') as String,
          'brand'      : (m['brand'] ?? '') as String,
          'brandId'    : (m['brandId'] ?? '') as String,
          'category'   : (m['category'] ?? '') as String,
          'categoryId' : (m['categoryId'] ?? '') as String,
          'price'      : (m['price'] ?? 0) as num,
          'stock'      : (m['stock'] ?? 0) as num,
          'image'      : (m['image'] ?? '') as String,
          'description': (m['description'] ?? '') as String,
          'createdAt'  : m['createdAt'],
          'updatedAt'  : m['updatedAt'],
        };
      }).toList(),
    );
  }

  /// เพิ่ม / อัปเดต / ลบ สินค้า
  static Future<void> addProduct(Map<String, dynamic> data) {
    return _db.collection('products').add(data);
  }

  static Future<void> updateProduct(String id, Map<String, dynamic> data) {
    return _db.collection('products').doc(id).update(data);
  }

  static Future<void> deleteProduct(String id) {
    return _db.collection('products').doc(id).delete();
  }

  /// สร้าง/แก้สินค้าแบบ merge + เก็บ nameLower ไว้ค้นหา/เรียง
  static Future<void> saveProduct(String id, Map<String, dynamic> data) {
    final name = (data['name'] ?? '') as String;
    final map = {
      ...data,
      'nameLower': name.toLowerCase().trim(),
      'updatedAt': _now,
    };
    return _db.collection('products').doc(id).set(map, SetOptions(merge: true));
  }

  /// ดึง “สินค้า + ชื่อแบรนด์/หมวดหมู่” (ครั้งเดียวแบบ Future)
  /// ใช้ใน ProductProvider.loadProducts()
  static Future<List<Product>> getProductsWithDetails() async {
    final raw = await watchProducts().first;

    // ดึงชื่อแบรนด์/หมวดทั้งหมดครั้งเดียว
    final brandsSnap = await _db.collection('brands').get();
    final catsSnap   = await _db.collection('categories').get();
    final brandNames = {for (var d in brandsSnap.docs) d.id: (d.data()['name'] ?? '') as String};
    final catNames   = {for (var d in catsSnap.docs)   d.id: (d.data()['name'] ?? '') as String};

    // สร้าง Product พร้อมอัดชื่อแบรนด์/หมวด
    return raw.map((m) {
      final p = Product.fromMap(m);
      return Product(
        id: p.id,
        name: p.name,
        brandId: p.brandId,
        categoryId: p.categoryId,
        price: p.price,
        stock: p.stock,
        image: p.image,
        description: p.description,
        updatedAt: p.updatedAt,
        createdAt: p.createdAt,
        brandName: brandNames[p.brandId],
        categoryName: catNames[p.categoryId],
      );
    }).toList();
  }

  // ========== CART ==========

  static Stream<List<Map<String, dynamic>>> watchCart(String uid) {
    return _db
        .collection('users').doc(uid)
        .collection('cart')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'productId': d.id, ...d.data()}).toList());
  }

  static Future<void> addToCart(String uid, String productId, {int qty = 1}) {
    final ref = _db.collection('users').doc(uid).collection('cart').doc(productId);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) {
        final cur = (snap.data()!['qty'] ?? 0) as int;
        tx.update(ref, {'qty': cur + qty, 'addedAt': _now});
      } else {
        tx.set(ref, {'qty': qty, 'addedAt': _now});
      }
    });
  }

  static Future<void> removeFromCart(String uid, String productId) {
    return _db.collection('users').doc(uid).collection('cart').doc(productId).delete();
  }

  /// เคลียร์ตะกร้าหลังสั่งซื้อ
  static Future<void> clearUserCart(String uid) async {
    final q = await _db.collection('users').doc(uid).collection('cart').get();
    final b = _db.batch();
    for (final d in q.docs) {
      b.delete(d.reference);
    }
    await b.commit();
  }

  // ========== ORDERS ==========

  /// สร้างออเดอร์ (id สั้นอ่านง่าย) + คัดลอก ref ไป /users/{uid}/orders (ออปชัน)
  static Future<String> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> address, // {name,line1,district,province,zip,phone}
    required double itemsTotal,
    required double shippingFee,
    required double grandTotal,
    required String paymentMethod,         // 'Mobile Banking' ฯลฯ
    required String status,                // 'pending'|'paid'|'preparing'|'shipped'...
    required String userId,                // uid หรือ 'guest'
    String? orderId,
  }) async {
    final id  = (orderId?.trim().isNotEmpty ?? false) ? orderId!.trim() : _shortOrderId();
    final ref = _db.collection('orders').doc(id);

    await ref.set({
      'orderId'      : id,
      'userId'       : userId,
      'items'        : items,
      'address'      : address,
      'itemsTotal'   : itemsTotal,
      'shippingFee'  : shippingFee,
      'grandTotal'   : grandTotal,
      'paymentMethod': paymentMethod,
      'status'       : status,
      'statusLower'  : status.toLowerCase(),
      'createdAt'    : _now,
      'updatedAt'    : _now,
    });

    if (userId.isNotEmpty && userId != 'guest') {
      await _db
          .collection('users').doc(userId)
          .collection('orders').doc(id)
          .set({'orderRef': ref.path, 'createdAt': _now});
    }
    return id;
  }

  /// สตรีมออเดอร์ (ใช้ในหลังบ้าน)
  static Stream<List<Map<String, dynamic>>> watchOrders({
    List<String>? statuses, // เช่น ['paid','preparing']
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> q =
        _db.collection('orders').orderBy('createdAt', descending: true);
    if (statuses != null && statuses.isNotEmpty) {
      q = q.where('status', whereIn: statuses);
    }
    return q.limit(limit).snapshots().map(
      (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
    );
  }
}
