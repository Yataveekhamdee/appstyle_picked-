import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';

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
        // ป้องกัน null/type error และเพิ่ม brandId, categoryId
        return {
          'id': d.id,
          'name': (m['name'] ?? '') as String,
          'brand': (m['brand'] ?? '') as String,
          'brandId': (m['brandId'] ?? '') as String,
          'category': (m['category'] ?? '') as String,
          'categoryId': (m['categoryId'] ?? '') as String,
          'price': (m['price'] ?? 0) as num,
          'stock': (m['stock'] ?? 0) as num,
          'image': (m['image'] ?? '') as String,
          'description': (m['description'] ?? '') as String,
          'updatedAt': m['updatedAt'],
          'createdAt': m['createdAt'],
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

  /// เพิ่มสินค้าใหม่
  static Future<void> addProduct(Map<String, dynamic> productData) async {
    await _db.collection('products').add(productData);
  }

  /// อัปเดตสินค้า
  static Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    await _db.collection('products').doc(productId).update(productData);
  }

  /// ลบสินค้า
  static Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
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

  // -------------------- BRANDS --------------------

  /// ดึงข้อมูลแบรนด์ทั้งหมด
  static Stream<List<Brand>> watchBrands() {
    return _db.collection('brands').orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Brand.fromFirestore(doc)).toList(),
        );
  }

  /// ดึงข้อมูลแบรนด์ตาม ID
  static Future<Brand?> getBrandById(String brandId) async {
    try {
      final doc = await _db.collection('brands').doc(brandId).get();
      if (doc.exists) {
        return Brand.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// ดึงข้อมูลแบรนด์หลายตัวพร้อมกัน
  static Future<Map<String, Brand>> getBrandsByIds(List<String> brandIds) async {
    final Map<String, Brand> brands = {};
    
    for (final brandId in brandIds) {
      try {
        final brand = await getBrandById(brandId);
        if (brand != null) {
          brands[brandId] = brand;
        }
      } catch (e) {
        // Skip error brands
      }
    }
    
    return brands;
  }

  // -------------------- CATEGORIES --------------------

  /// ดึงข้อมูลหมวดหมู่ทั้งหมด
  static Stream<List<Category>> watchCategories() {
    return _db.collection('categories').orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList(),
        );
  }

  /// ดึงข้อมูลหมวดหมู่ตาม ID
  static Future<Category?> getCategoryById(String categoryId) async {
    try {
      final doc = await _db.collection('categories').doc(categoryId).get();
      if (doc.exists) {
        return Category.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// ดึงข้อมูลหมวดหมู่หลายตัวพร้อมกัน
  static Future<Map<String, Category>> getCategoriesByIds(List<String> categoryIds) async {
    final Map<String, Category> categories = {};
    
    for (final categoryId in categoryIds) {
      try {
        final category = await getCategoryById(categoryId);
        if (category != null) {
          categories[categoryId] = category;
        }
      } catch (e) {
        // Skip error categories
      }
    }
    
    return categories;
  }

  // -------------------- PRODUCTS WITH BRAND/CATEGORY INFO --------------------

  /// ดึงข้อมูลสินค้าพร้อมข้อมูลแบรนด์และหมวดหมู่ (Stream)
  static Stream<List<Product>> watchProductsWithDetails() {
    return watchProducts().asyncMap((productsData) async {
      final List<Product> products = [];
      
      // ดึงข้อมูลแบรนด์และหมวดหมู่ทั้งหมด
      final brandsSnapshot = await _db.collection('brands').get();
      final categoriesSnapshot = await _db.collection('categories').get();
      
      final Map<String, String> brandNames = {};
      final Map<String, String> categoryNames = {};
      
      for (final doc in brandsSnapshot.docs) {
        brandNames[doc.id] = doc.data()['name'] ?? '';
      }
      
      for (final doc in categoriesSnapshot.docs) {
        categoryNames[doc.id] = doc.data()['name'] ?? '';
      }
      
      // สร้าง Product objects พร้อมชื่อแบรนด์และหมวดหมู่
      for (final data in productsData) {
        final product = Product.fromMap(data);
        final productWithDetails = Product(
          id: product.id,
          name: product.name,
          brandId: product.brandId,
          categoryId: product.categoryId,
          price: product.price,
          stock: product.stock,
          image: product.image,
          description: product.description,
          updatedAt: product.updatedAt,
          createdAt: product.createdAt,
          brandName: brandNames[product.brandId],
          categoryName: categoryNames[product.categoryId],
        );
        products.add(productWithDetails);
      }
      
      return products;
    });
  }

  /// ดึงข้อมูลสินค้าพร้อมข้อมูลแบรนด์และหมวดหมู่ (Future)
  static Future<List<Product>> getProductsWithDetails() async {
    print('Debug FirestoreService - getProductsWithDetails START');
    final productsData = await watchProducts().first;
    print('Debug FirestoreService - Raw products data: ${productsData.length}');
    
    // Debug: แสดงข้อมูลดิบจาก Firestore
    for (var data in productsData) {
      print('Debug FirestoreService - Raw data: $data');
    }
    
    final List<Product> products = [];
    
    // ดึงข้อมูลแบรนด์และหมวดหมู่ทั้งหมด
    final brandsSnapshot = await _db.collection('brands').get();
    final categoriesSnapshot = await _db.collection('categories').get();
    
    print('Debug FirestoreService - Brands count: ${brandsSnapshot.docs.length}');
    print('Debug FirestoreService - Categories count: ${categoriesSnapshot.docs.length}');
    
    final Map<String, String> brandNames = {};
    final Map<String, String> categoryNames = {};
    
    for (final doc in brandsSnapshot.docs) {
      final brandName = doc.data()['name'] ?? '';
      brandNames[doc.id] = brandName;
      print('Debug FirestoreService - Brand: ${doc.id} -> $brandName');
    }
    
    for (final doc in categoriesSnapshot.docs) {
      final categoryName = doc.data()['name'] ?? '';
      categoryNames[doc.id] = categoryName;
      print('Debug FirestoreService - Category: ${doc.id} -> $categoryName');
    }
    
    // สร้าง Product objects พร้อมชื่อแบรนด์และหมวดหมู่
    for (final data in productsData) {
      final product = Product.fromMap(data);
      print('Debug FirestoreService - Product fromMap: brandId=${product.brandId}, categoryId=${product.categoryId}');
      
      final productWithDetails = Product(
        id: product.id,
        name: product.name,
        brandId: product.brandId,
        categoryId: product.categoryId,
        price: product.price,
        stock: product.stock,
        image: product.image,
        description: product.description,
        updatedAt: product.updatedAt,
        createdAt: product.createdAt,
        brandName: brandNames[product.brandId],
        categoryName: categoryNames[product.categoryId],
      );
      
      print('Debug FirestoreService - Product with details: brandId=${productWithDetails.brandId}, brandName=${productWithDetails.brandName}');
      products.add(productWithDetails);
    }
    
    print('Debug FirestoreService - Final products count: ${products.length}');
    print('Debug FirestoreService - getProductsWithDetails END');
    return products;
  }
}
