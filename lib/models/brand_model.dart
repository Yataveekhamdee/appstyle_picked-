import 'package:cloud_firestore/cloud_firestore.dart';

class Brand {
  final String id;
  final String name;
  final String description;
  final String? logo;
  final String? website;
  final bool isActive;
  final int productCount;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Brand({
    required this.id,
    required this.name,
    required this.description,
    this.logo,
    this.website,
    required this.isActive,
    required this.productCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Brand.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Brand(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      logo: data['logo'] as String?,
      website: data['website'] as String?,
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
      'logo': logo,
      'website': website,
      'isActive': isActive,
      'productCount': productCount,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toFirestoreForCreate() {
    return {
      'name': name,
      'description': description,
      'logo': logo,
      'website': website,
      'isActive': isActive,
      'productCount': productCount,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Brand copyWith({
    String? id,
    String? name,
    String? description,
    String? logo,
    String? website,
    bool? isActive,
    int? productCount,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Brand(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      website: website ?? this.website,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Brand(id: $id, name: $name, description: $description, isActive: $isActive, productCount: $productCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Brand && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}


