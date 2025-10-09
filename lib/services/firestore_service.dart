import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final _db = FirebaseFirestore.instance;

  // -------------------- PRODUCTS --------------------

  /// stream รายการสินค้า (เลือก filter ได้)
  static Stream<List<Map<String, dynamic>>> watchProducts({
    String? brand,
    String? category,
  }) {
    Query col = _db.collection('products');
    if (brand != null && brand.isNotEmpty) {
      col = col.where('brand', isEqualTo: brand);
    }
    if (category != null && category.isNotEmpty) {
      col = col.where('category', isEqualTo: category);
    }
    return col.orderBy('updatedAt', descending: true).snapshots().map(
      (q) => q.docs.map((d) {
        final m = d.data() as Map<String, dynamic>;
        // ป้องกัน null/type error
        return {
          'id': d.id,
          'name': (m['name'] ?? '') as String,
          'brand': (m['brand'] ?? '') as String,
          'category': (m['category'] ?? '') as String,
          'price': (m['price'] ?? 0) as num,
          'stock': (m['stock'] ?? 0) as num,
          'image': (m['image'] ?? '') as String,
          'updatedAt': m['updatedAt'],
        };
      }).toList(),
    );
  }

  /// ค้นหาชื่อสินค้าแบบ prefix (พิมพ์คำขึ้นต้น)
  static Stream<List<Map<String, dynamic>>> searchByNamePrefix(String term) {
    final t = term.trim().toLowerCase();
    if (t.isEmpty) {
      return watchProducts();
    }
    // ต้องมี index: orderBy(nameLower)
    return _db
        .collection('products')
        .orderBy('nameLower')
        .startAt([t])
        .endAt(['$t\uf8ff'])
        .limit(30)
        .snapshots()
        .map(_mapDocs);
  }

  /// ค้นหาด้วย keywords (ใส่ array ในสินค้า) – ไม่ต้องสร้าง index
  static Stream<List<Map<String, dynamic>>> searchByKeyword(String term) {
    final t = term.trim().toLowerCase();
    if (t.isEmpty) return watchProducts();
    return _db
        .collection('products')
        .where('keywords', arrayContains: t)
        .limit(30)
        .snapshots()
        .map(_mapDocs);
  }

  static List<Map<String, dynamic>> _mapDocs(QuerySnapshot q) => q.docs.map((d) {
        final m = d.data() as Map<String, dynamic>;
        return {
          'id': d.id,
          'name': (m['name'] ?? '') as String,
          'brand': (m['brand'] ?? '') as String,
          'category': (m['category'] ?? '') as String,
          'price': (m['price'] ?? 0) as num,
          'stock': (m['stock'] ?? 0) as num,
          'image': (m['image'] ?? '') as String,
          'updatedAt': m['updatedAt'],
        };
      }).toList();

  /// สร้าง/แก้สินค้า (ใช้ในหลังบ้าน)
  static Future<void> saveProduct(String id, Map<String, dynamic> data) async {
    final now = FieldValue.serverTimestamp();
    final name = (data['name'] ?? '') as String;
    final map = {
      ...data,
      'nameLower': name.toLowerCase().trim(),
      'updatedAt': now,
    };
    await _db.collection('products').doc(id).set(map, SetOptions(merge: true));
  }

  static Future<void> deleteProduct(String id) =>
      _db.collection('products').doc(id).delete();

  // -------------------- CART --------------------

  static Stream<List<Map<String, dynamic>>> watchCart(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((q) => q.docs.map((d) {
              final m = d.data();
              return {'productId': d.id, ...m};
            }).toList());
  }

  static Future<void> addToCart(String uid, String productId, {int qty = 1}) {
    final ref = _db.collection('users').doc(uid).collection('cart').doc(productId);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) {
        final cur = (snap.data()!['qty'] ?? 0) as int;
        tx.update(ref, {'qty': cur + qty, 'addedAt': FieldValue.serverTimestamp()});
      } else {
        tx.set(ref, {'qty': qty, 'addedAt': FieldValue.serverTimestamp()});
      }
    });
  }

  static Future<void> removeFromCart(String uid, String productId) =>
      _db.collection('users').doc(uid).collection('cart').doc(productId).delete();

  // -------------------- ORDERS --------------------

  static Future<String> placeOrder(String uid, List<Map<String, dynamic>> items) async {
    // สรุปราคา
    num total = 0;
    for (final it in items) {
      total += (it['price'] as num) * (it['qty'] as num);
    }
    final ref = _db.collection('users').doc(uid).collection('orders').doc();
    await ref.set({
      'items': items,
      'total': total,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    // เคลียร์ตะกร้า
    final cart = await _db.collection('users').doc(uid).collection('cart').get();
    final batch = _db.batch();
    for (final d in cart.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
    return ref.id;
  }
}
