import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analytics_model.dart' as analytics;

class AnalyticsService {
  static final _firestore = FirebaseFirestore.instance;

  /// ดึงข้อมูลสถิติการขายทั้งหมด
  static Future<analytics.SalesAnalytics> getSalesAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final now = DateTime.now();
      final start = startDate ?? DateTime(now.year, now.month - 6, 1);
      final end = endDate ?? DateTime(now.year, now.month, now.day);

      // ดึงข้อมูลคำสั่งซื้อ
      final ordersQuery = _firestore
          .collectionGroup('orders')
          .where('orderDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('orderDate', isLessThanOrEqualTo: Timestamp.fromDate(end));

      final ordersSnapshot = await ordersQuery.get();
      final orders = ordersSnapshot.docs
          .map((doc) => analytics.Order.fromFirestore(doc))
          .toList();

      // คำนวณสถิติพื้นฐาน
      final totalRevenue = orders.fold<double>(0, (sum, order) => sum + order.totalAmount);
      final totalOrders = orders.length;
      final averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

      // ดึงข้อมูลสินค้าและลูกค้า
      final productsSnapshot = await _firestore.collection('products').get();
      final totalProducts = productsSnapshot.docs.length;

      final customersSnapshot = await _firestore.collection('users').get();
      final totalCustomers = customersSnapshot.docs.length;

      // คำนวณสถิติหมวดหมู่
      final categorySales = _calculateCategorySales(orders);

      // คำนวณสถิติแบรนด์
      final brandSales = _calculateBrandSales(orders);

      // คำนวณสถิติรายเดือน
      final monthlySales = _calculateMonthlySales(orders, start, end);

      return analytics.SalesAnalytics(
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        totalProducts: totalProducts,
        totalCustomers: totalCustomers,
        averageOrderValue: averageOrderValue,
        categorySales: categorySales,
        brandSales: brandSales,
        monthlySales: monthlySales,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('ไม่สามารถดึงข้อมูลสถิติได้: $e');
    }
  }

  /// คำนวณสถิติหมวดหมู่
  static List<analytics.CategorySales> _calculateCategorySales(List<analytics.Order> orders) {
    final Map<String, double> categoryRevenue = {};
    final Map<String, int> categoryOrders = {};
    final Map<String, int> categoryProducts = {};

    double totalRevenue = 0;

    for (final order in orders) {
      for (final item in order.items) {
        final category = item.category;
        
        categoryRevenue[category] = (categoryRevenue[category] ?? 0) + item.subtotal;
        categoryOrders[category] = (categoryOrders[category] ?? 0) + item.quantity;
        categoryProducts[category] = (categoryProducts[category] ?? 0) + 1;
        
        totalRevenue += item.subtotal;
      }
    }

    return categoryRevenue.entries.map((entry) {
      final category = entry.key;
      final revenue = entry.value;
      final percentage = totalRevenue > 0 ? (revenue / totalRevenue) * 100 : 0.0;

      return analytics.CategorySales(
        categoryName: category,
        revenue: revenue,
        orderCount: categoryOrders[category] ?? 0,
        productCount: categoryProducts[category] ?? 0,
        percentage: percentage,
      );
    }).toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
  }

  /// คำนวณสถิติแบรนด์
  static List<analytics.BrandSales> _calculateBrandSales(List<analytics.Order> orders) {
    final Map<String, double> brandRevenue = {};
    final Map<String, int> brandOrders = {};
    final Map<String, int> brandProducts = {};

    double totalRevenue = 0;

    for (final order in orders) {
      for (final item in order.items) {
        final brand = item.brand;
        
        brandRevenue[brand] = (brandRevenue[brand] ?? 0) + item.subtotal;
        brandOrders[brand] = (brandOrders[brand] ?? 0) + item.quantity;
        brandProducts[brand] = (brandProducts[brand] ?? 0) + 1;
        
        totalRevenue += item.subtotal;
      }
    }

    return brandRevenue.entries.map((entry) {
      final brand = entry.key;
      final revenue = entry.value;
      final percentage = totalRevenue > 0 ? (revenue / totalRevenue) * 100 : 0.0;

      return analytics.BrandSales(
        brandName: brand,
        revenue: revenue,
        orderCount: brandOrders[brand] ?? 0,
        productCount: brandProducts[brand] ?? 0,
        percentage: percentage,
      );
    }).toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
  }

  /// คำนวณสถิติรายเดือน
  static List<analytics.MonthlySales> _calculateMonthlySales(
    List<analytics.Order> orders,
    DateTime startDate,
    DateTime endDate,
  ) {
    final Map<String, analytics.MonthlySales> monthlyData = {};

    // สร้างรายการเดือน
    DateTime current = DateTime(startDate.year, startDate.month, 1);
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      final monthKey = '${current.month.toString().padLeft(2, '0')}/${current.year}';
      final monthName = _getMonthName(current.month);
      
      monthlyData[monthKey] = analytics.MonthlySales(
        month: monthName,
        year: current.year,
        revenue: 0,
        orderCount: 0,
        productCount: 0,
      );

      current = DateTime(current.year, current.month + 1, 1);
    }

    // คำนวณข้อมูลจากคำสั่งซื้อ
    for (final order in orders) {
      final monthKey = '${order.orderDate.month.toString().padLeft(2, '0')}/${order.orderDate.year}';
      
      if (monthlyData.containsKey(monthKey)) {
        final existing = monthlyData[monthKey]!;
        monthlyData[monthKey] = analytics.MonthlySales(
          month: existing.month,
          year: existing.year,
          revenue: existing.revenue + order.totalAmount,
          orderCount: existing.orderCount + 1,
          productCount: existing.productCount + order.items.length,
        );
      }
    }

    return monthlyData.values.toList()
      ..sort((a, b) => a.year == b.year ? a.month.compareTo(b.month) : a.year.compareTo(b.year));
  }

  /// ดึงชื่อเดือน
  static String _getMonthName(int month) {
    const months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return months[month - 1];
  }

  /// ดึงข้อมูลคำสั่งซื้อล่าสุด
  static Stream<List<analytics.Order>> watchRecentOrders({int limit = 10}) {
    return _firestore
        .collectionGroup('orders')
        .orderBy('orderDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => analytics.Order.fromFirestore(doc))
            .toList());
  }

  /// ดึงข้อมูลสินค้าขายดี
  static Future<List<Map<String, dynamic>>> getTopSellingProducts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final now = DateTime.now();
      final start = startDate ?? DateTime(now.year, now.month - 1, 1);
      final end = endDate ?? DateTime(now.year, now.month, now.day);

      final ordersQuery = _firestore
          .collectionGroup('orders')
          .where('orderDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('orderDate', isLessThanOrEqualTo: Timestamp.fromDate(end));

      final ordersSnapshot = await ordersQuery.get();
      final orders = ordersSnapshot.docs
          .map((doc) => analytics.Order.fromFirestore(doc))
          .toList();

      final Map<String, Map<String, dynamic>> productStats = {};

      for (final order in orders) {
        for (final item in order.items) {
          final productId = item.productId;
          
          if (productStats.containsKey(productId)) {
            final stats = productStats[productId]!;
            stats['quantity'] = (stats['quantity'] as int) + item.quantity;
            stats['revenue'] = (stats['revenue'] as double) + item.subtotal;
            stats['orders'] = (stats['orders'] as int) + 1;
          } else {
            productStats[productId] = {
              'productId': productId,
              'productName': item.productName,
              'brand': item.brand,
              'category': item.category,
              'image': item.image,
              'quantity': item.quantity,
              'revenue': item.subtotal,
              'orders': 1,
            };
          }
        }
      }

      final topProducts = productStats.values.toList()
        ..sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

      return topProducts.take(limit).toList();
    } catch (e) {
      throw Exception('ไม่สามารถดึงข้อมูลสินค้าขายดีได้: $e');
    }
  }

  /// สร้างรายงานการขาย
  static Future<Map<String, dynamic>> generateSalesReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final analytics = await getSalesAnalytics(
        startDate: startDate,
        endDate: endDate,
      );

      final topProducts = await getTopSellingProducts(
        startDate: startDate,
        endDate: endDate,
        limit: 20,
      );

      return {
        'analytics': analytics,
        'topProducts': topProducts,
        'generatedAt': DateTime.now(),
        'period': {
          'startDate': startDate ?? DateTime.now().subtract(const Duration(days: 30)),
          'endDate': endDate ?? DateTime.now(),
        },
      };
    } catch (e) {
      throw Exception('ไม่สามารถสร้างรายงานได้: $e');
    }
  }
}
