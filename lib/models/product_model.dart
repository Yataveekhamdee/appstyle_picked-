class Product {
  final String id;
  final String name;
  final String brandId;      // เปลี่ยนจาก brand เป็น brandId
  final String categoryId;   // เปลี่ยนจาก category เป็น categoryId
  final double price;
  final int stock;
  final String image;
  final String? description;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  
  // สำหรับแสดงชื่อแบรนด์และหมวดหมู่
  final String? brandName;
  final String? categoryName;

  Product({
    required this.id,
    required this.name,
    required this.brandId,
    required this.categoryId,
    required this.price,
    required this.stock,
    required this.image,
    this.description,
    this.updatedAt,
    this.createdAt,
    this.brandName,
    this.categoryName,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      brandId: map['brandId'] ?? map['brand'] ?? '', // รองรับทั้ง brandId และ brand
      categoryId: map['categoryId'] ?? map['category'] ?? '', // รองรับทั้ง categoryId และ category
      price: (map['price'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      image: map['image'] ?? '',
      description: map['description'],
      updatedAt: map['updatedAt']?.toDate(),
      createdAt: map['createdAt']?.toDate(),
      brandName: map['brandName'],
      categoryName: map['categoryName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brandId': brandId,
      'categoryId': categoryId,
      'price': price,
      'stock': stock,
      'image': image,
      'description': description,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
      if (brandName != null) 'brandName': brandName,
      if (categoryName != null) 'categoryName': categoryName,
    };
  }
  
  // Helper methods สำหรับ backward compatibility
  String get brand => brandName ?? brandId;
  String get category => categoryName ?? categoryId;
}
