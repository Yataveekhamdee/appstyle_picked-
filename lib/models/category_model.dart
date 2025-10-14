import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final String? image;
  final bool isActive;
  final int productCount;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.isActive,
    required this.productCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      image: data['image'] as String?,
      isActive: (data['isActive'] ?? true) as bool,
      productCount: (data['productCount'] ?? 0) as int,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'isActive': isActive,
      'productCount': productCount,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toFirestoreForCreate() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'isActive': isActive,
      'productCount': productCount,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    bool? isActive,
    int? productCount,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description, isActive: $isActive, productCount: $productCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}


