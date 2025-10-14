import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_store.dart';
import '../../providers/product_provider.dart';
import '../../providers/brand_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/simple_network_image_widget.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  int selected = 0;

  @override
  void initState() {
    super.initState();
    // โหลดสินค้าและแบรนด์จาก Firebase เมื่อหน้าโหลด
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<BrandProvider>().loadBrands();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductProvider, BrandProvider>(
      builder: (context, productProvider, brandProvider, child) {
        // สร้างรายการแบรนด์จาก Firebase
        final filters = ['See All', ...brandProvider.activeBrands.map((brand) => brand.name)];
        final visibleItems = productProvider.filteredProducts;

        // กำหนดจำนวนคอลัมน์ตามความกว้างหน้าจอ
        final width = MediaQuery.of(context).size.width;
        final cols = width >= 900 ? 4 : width >= 600 ? 3 : 2;

        if (productProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('สินค้า')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (productProvider.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('สินค้า')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('เกิดข้อผิดพลาด: ${productProvider.error}'),
                  ElevatedButton(
                    onPressed: () => productProvider.loadProducts(),
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF7F7F7),

      // FAB “เทรนด์”
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/trends'),
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFF7B57FF),
          foregroundColor: Colors.white,
          elevation: 4,
          child: const FittedBox(
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Text('เทรนด์', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: SafeArea(
        child: Column(
          children: [
            // แถวค้นหา + ปุ่มตะกร้า
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Row(
                children: [
                  _roundIcon(Icons.arrow_back, onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 8),
                  const Expanded(child: _SearchField()),
                  const SizedBox(width: 8),
                  _roundIcon(Icons.shopping_cart_outlined,
                      onTap: () => Navigator.pushNamed(context, '/cart')),
                ],
              ),
            ),

            // เนื้อหาหลัก: ซ้าย = รายการแบรนด์แนวตั้ง / ขวา = กริดสินค้า
            Expanded(
              child: Row(
                children: [
                  // แถบซ้าย (ปุ่มแบรนด์เรียงลง)
                  Container(
                    width: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(color: Color(0xFFECECEC)),
                      ),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filters.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (_, i) {
                        final isSel = i == selected;
                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            setState(() => selected = i);
                            productProvider.filterByBrand(filters[i]);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSel ? Colors.black : const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              filters[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSel ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFECECEC)),

                  // กริดสินค้า
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 120),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 14,
                        childAspectRatio: .72,
                      ),
                      itemCount: visibleItems.length,
                      itemBuilder: (_, i) => _ProductCard(product: visibleItems[i]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

          // แทบเมนูล่างเหมือนหน้า Home
          bottomNavigationBar: _BottomBar(
            showBadge: false,
            onTapHome: () => Navigator.pushNamed(context, '/'),
            onTapSearch: () => Navigator.pushNamed(context, '/products'),
            onTapCart: () => Navigator.pushNamed(context, '/cart'),
            onTapUser: () => Navigator.pushNamed(context, '/login'),
          ),
        );
      },
    );
  }

  Widget _roundIcon(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Ink(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.4),
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black, width: 1.4),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search here …',
          hintStyle: TextStyle(color: Colors.black45),
          prefixIcon: Icon(Icons.search, color: Colors.black87, size: 22),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 8),
        ),
      ),
    );
  }
}

/// ===== Card สินค้า =====
class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x14000000))],
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูป
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SimpleSmartImageWidget(
                      imageUrl: product.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // ปุ่มหัวใจ
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.92),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border),
                      ),
                    ),
                  ),
                  // ปุ่มตะกร้าลอยมุมขวาล่าง
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // ➜ เพิ่มลง cart 1 ชิ้น แล้วพาไปหน้าตะกร้า
                        cartStore.add(
                          title: product.name,
                          price: product.price,
                          image: product.image,
                          qty: 1,
                        );
                        Navigator.pushNamed(context, '/cart');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6)],
                        ),
                        child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ชื่อ + ราคา
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  // แสดงชื่อแบรนด์
                  if (product.brandName != null)
                    Text(
                      product.brandName!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 4),
                  // แสดงชื่อหมวดหมู่
                  if (product.categoryName != null)
                    Text(
                      product.categoryName!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '฿${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== Bottom bar แบบเดียวกับหน้า main =====
class _BottomBar extends StatelessWidget {
  final bool showBadge;
  final VoidCallback onTapHome, onTapSearch, onTapCart, onTapUser;

  const _BottomBar({
    super.key,
    required this.showBadge,
    required this.onTapHome,
    required this.onTapSearch,
    required this.onTapCart,
    required this.onTapUser,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.black.withOpacity(.88),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 58,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BarItem(icon: Icons.home_outlined, label: 'หน้าหลัก', onTap: onTapHome),
            _BarItem(icon: Icons.search, label: 'หมวดหมู่', onTap: onTapSearch),

            const SizedBox(width: 48), // เว้นที่ให้ FAB

            GestureDetector(
              onTap: onTapCart,
              child: SizedBox(
                width: 72,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
                    SizedBox(height: 1),
                    Text('ตะกร้า', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ),

            _BarItem(icon: Icons.person_outline, label: 'ฉัน', onTap: onTapUser),
          ],
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BarItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
