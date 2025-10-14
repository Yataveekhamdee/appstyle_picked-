import 'package:cloud_firestore/cloud_firestore.dart';

class SalesAnalytics {
  final double totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final int totalCustomers;
  final double averageOrderValue;
  final List<CategorySales> categorySales;
  final List<BrandSales> brandSales;
  final List<MonthlySales> monthlySales;
  final DateTime lastUpdated;

  SalesAnalytics({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalCustomers,
    required this.averageOrderValue,
    required this.categorySales,
    required this.brandSales,
    required this.monthlySales,
    required this.lastUpdated,
  });

  factory SalesAnalytics.empty() {
    return SalesAnalytics(
      totalRevenue: 0,
      totalOrders: 0,
      totalProducts: 0,
      totalCustomers: 0,
      averageOrderValue: 0,
      categorySales: [],
      brandSales: [],
      monthlySales: [],
      lastUpdated: DateTime.now(),
    );
  }
}

class CategorySales {
  final String categoryName;
  final double revenue;
  final int orderCount;
  final int productCount;
  final double percentage;

  CategorySales({
    required this.categoryName,
    required this.revenue,
    required this.orderCount,
    required this.productCount,
    required this.percentage,
  });

  factory CategorySales.fromMap(Map<String, dynamic> map) {
    return CategorySales(
      categoryName: map['categoryName'] ?? '',
      revenue: (map['revenue'] ?? 0).toDouble(),
      orderCount: map['orderCount'] ?? 0,
      productCount: map['productCount'] ?? 0,
      percentage: (map['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryName': categoryName,
      'revenue': revenue,
      'orderCount': orderCount,
      'productCount': productCount,
      'percentage': percentage,
    };
  }
}

class BrandSales {
  final String brandName;
  final double revenue;
  final int orderCount;
  final int productCount;
  final double percentage;

  BrandSales({
    required this.brandName,
    required this.revenue,
    required this.orderCount,
    required this.productCount,
    required this.percentage,
  });

  factory BrandSales.fromMap(Map<String, dynamic> map) {
    return BrandSales(
      brandName: map['brandName'] ?? '',
      revenue: (map['revenue'] ?? 0).toDouble(),
      orderCount: map['orderCount'] ?? 0,
      productCount: map['productCount'] ?? 0,
      percentage: (map['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brandName': brandName,
      'revenue': revenue,
      'orderCount': orderCount,
      'productCount': productCount,
      'percentage': percentage,
    };
  }
}

class MonthlySales {
  final String month;
  final int year;
  final double revenue;
  final int orderCount;
  final int productCount;

  MonthlySales({
    required this.month,
    required this.year,
    required this.revenue,
    required this.orderCount,
    required this.productCount,
  });

  factory MonthlySales.fromMap(Map<String, dynamic> map) {
    return MonthlySales(
      month: map['month'] ?? '',
      year: map['year'] ?? DateTime.now().year,
      revenue: (map['revenue'] ?? 0).toDouble(),
      orderCount: map['orderCount'] ?? 0,
      productCount: map['productCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'year': year,
      'revenue': revenue,
      'orderCount': orderCount,
      'productCount': productCount,
    };
  }

  String get displayName => '$month $year';
}

class Order {
  final String id;
  final String customerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final Map<String, dynamic>? customerInfo;

  Order({
    required this.id,
    required this.customerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.deliveryDate,
    this.customerInfo,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryDate: (data['deliveryDate'] as Timestamp?)?.toDate(),
      customerInfo: data['customerInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': Timestamp.fromDate(orderDate),
      'deliveryDate': deliveryDate != null ? Timestamp.fromDate(deliveryDate!) : null,
      'customerInfo': customerInfo,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String brand;
  final String category;
  final double price;
  final int quantity;
  final String image;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.brand,
    required this.category,
    required this.price,
    required this.quantity,
    required this.image,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      brand: map['brand'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? 0) as int,
      image: map['image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'brand': brand,
      'category': category,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }

  double get subtotal => price * quantity;
}
