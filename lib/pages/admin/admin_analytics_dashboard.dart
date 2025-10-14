import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/analytics_model.dart';
import '../../services/analytics_service.dart';
import '../../providers/admin_auth_provider.dart';
import 'admin_login_page.dart';

class AdminAnalyticsDashboard extends StatefulWidget {
  const AdminAnalyticsDashboard({super.key});

  @override
  State<AdminAnalyticsDashboard> createState() => _AdminAnalyticsDashboardState();
}

class _AdminAnalyticsDashboardState extends State<AdminAnalyticsDashboard> {
  SalesAnalytics? _analytics;
  bool _isLoading = true;
  String? _error;
  DateTime _selectedStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _selectedEndDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _checkAdminPermission();
  }

  Future<void> _checkAdminPermission() async {
    final adminAuth = context.read<AdminAuthProvider>();
    
    if (!adminAuth.isLoggedIn || !adminAuth.isAdmin) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminLoginPage()),
        );
      }
      return;
    }
    
    await _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final analytics = await AnalyticsService.getSalesAnalytics(
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
      );
      
      if (mounted) {
        setState(() {
          _analytics = analytics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminAuthProvider>(
      builder: (context, adminAuth, child) {
        if (adminAuth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!adminAuth.isLoggedIn || !adminAuth.isAdmin) {
          return const AdminLoginPage();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Analytics Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadAnalytics,
              ),
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'products',
                    child: ListTile(
                      leading: Icon(Icons.inventory),
                      title: Text('จัดการสินค้า'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'categories',
                    child: ListTile(
                      leading: Icon(Icons.category),
                      title: Text('จัดการหมวดหมู่'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'brands',
                    child: ListTile(
                      leading: Icon(Icons.business),
                      title: Text('จัดการแบรนด์'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'dashboard',
                    child: ListTile(
                      leading: Icon(Icons.dashboard),
                      title: Text('Dashboard หลัก'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: _buildBody(),
          drawer: _buildDrawer(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('เกิดข้อผิดพลาด: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAnalytics,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    if (_analytics == null) {
      return const Center(
        child: Text('ไม่พบข้อมูล Analytics'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ฟิลเตอร์วันที่
          _buildDateFilter(),
          const SizedBox(height: 16),

          // สถิติหลัก
          _buildMainStats(),
          const SizedBox(height: 16),

          // สถิติหมวดหมู่
          _buildCategoryStats(),
          const SizedBox(height: 16),

          // สถิติแบรนด์
          _buildBrandStats(),
          const SizedBox(height: 16),

          // สถิติรายเดือน
          _buildMonthlyStats(),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ช่วงเวลา',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('วันที่เริ่มต้น'),
                    subtitle: Text('${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectStartDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('วันที่สิ้นสุด'),
                    subtitle: Text('${_selectedEndDate.day}/${_selectedEndDate.month}/${_selectedEndDate.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectEndDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loadAnalytics,
                icon: const Icon(Icons.filter_list),
                label: const Text('อัปเดตข้อมูล'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'รายได้รวม',
          '฿${_analytics!.totalRevenue.toStringAsFixed(0)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          'คำสั่งซื้อ',
          '${_analytics!.totalOrders} รายการ',
          Icons.shopping_cart,
          Colors.blue,
        ),
        _buildStatCard(
          'สินค้า',
          '${_analytics!.totalProducts} รายการ',
          Icons.inventory,
          Colors.orange,
        ),
        _buildStatCard(
          'ลูกค้า',
          '${_analytics!.totalCustomers} คน',
          Icons.people,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สถิติหมวดหมู่',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (_analytics!.categorySales.isEmpty)
              const Text('ไม่มีข้อมูล')
            else
              ..._analytics!.categorySales.map((category) => _buildCategoryItem(category)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(CategorySales category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(category.categoryName),
          ),
          Expanded(
            child: Text('฿${category.revenue.toStringAsFixed(0)}'),
          ),
          Expanded(
            child: Text('${category.percentage.toStringAsFixed(1)}%'),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สถิติแบรนด์',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (_analytics!.brandSales.isEmpty)
              const Text('ไม่มีข้อมูล')
            else
              ..._analytics!.brandSales.map((brand) => _buildBrandItem(brand)),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandItem(BrandSales brand) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(brand.brandName),
          ),
          Expanded(
            child: Text('฿${brand.revenue.toStringAsFixed(0)}'),
          ),
          Expanded(
            child: Text('${brand.percentage.toStringAsFixed(1)}%'),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สถิติรายเดือน',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (_analytics!.monthlySales.isEmpty)
              const Text('ไม่มีข้อมูล')
            else
              ..._analytics!.monthlySales.map((month) => _buildMonthlyItem(month)),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyItem(MonthlySales month) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(month.displayName),
          ),
          Expanded(
            child: Text('฿${month.revenue.toStringAsFixed(0)}'),
          ),
          Expanded(
            child: Text('${month.orderCount} รายการ'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Analytics Dashboard',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard หลัก'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/admin');
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('จัดการสินค้า'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin/products');
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('จัดการหมวดหมู่'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin/categories');
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('จัดการแบรนด์'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin/brands');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'products':
        Navigator.pushNamed(context, '/admin/products');
        break;
      case 'categories':
        Navigator.pushNamed(context, '/admin/categories');
        break;
      case 'brands':
        Navigator.pushNamed(context, '/admin/brands');
        break;
      case 'dashboard':
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case 'logout':
        _handleLogout();
        break;
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบ Admin หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<AdminAuthProvider>().signOut();
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminLoginPage()),
        );
      }
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _selectedStartDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: _selectedStartDate,
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _selectedEndDate = date);
    }
  }
}
