import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_store.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/simple_network_image_widget.dart';

class BrandListPage extends StatefulWidget {
  final String brandName;
  const BrandListPage({super.key, required this.brandName});

  @override
  State<BrandListPage> createState() => _BrandListPageState();
}

class _BrandListPageState extends State<BrandListPage> {
  @override
  void initState() {
    super.initState();
    // โหลดสินค้าจาก Firebase เมื่อหน้าโหลด
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('Debug BrandListPage - Brand Name: ${widget.brandName}');
      final productProvider = context.read<ProductProvider>();
      
      // โหลดสินค้าจาก Firebase ก่อน
      await productProvider.loadProducts();
      print('Debug BrandListPage - After loadProducts: ${productProvider.products.length}');
      
      // ดูสินค้าทั้งหมดก่อน filter
      for (var product in productProvider.products) {
        print('Debug BrandListPage - Product: ${product.name}');
        print('Debug BrandListPage - Product brandId: ${product.brandId}');
        print('Debug BrandListPage - Product brand: ${product.brand}');
      }
      
      // ใช้ filterByBrand
      productProvider.filterByBrand(widget.brandName);
      print('Debug BrandListPage - After filterByBrand: ${productProvider.filteredProducts.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final brandProducts = productProvider.filteredProducts;
        
        print('Debug BrandListPage - Brand Name: ${widget.brandName}');
        print('Debug BrandListPage - Selected Brand: ${productProvider.selectedBrand}');
        print('Debug BrandListPage - Filtered Products Count: ${brandProducts.length}');
        print('Debug BrandListPage - Total Products: ${productProvider.products.length}');

        if (productProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(widget.brandName, style: const TextStyle(fontWeight: FontWeight.w700)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (productProvider.error != null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(widget.brandName, style: const TextStyle(fontWeight: FontWeight.w700)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
            ),
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
          backgroundColor: Colors.white,
          extendBody: true,
          appBar: AppBar(
            title: Text(widget.brandName, style: const TextStyle(fontWeight: FontWeight.w700)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
          ),

          // FAB "เทรนด์"
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

          body: brandProducts.isEmpty
              ? const Center(
                  child: Text(
                    'ไม่มีสินค้าในแบรนด์นี้',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 14.0,
                      childAspectRatio: .76,
                    ),
                    itemCount: brandProducts.length,
                    itemBuilder: (_, i) => _ProductCard(product: brandProducts[i]),
                  ),
                ),

          // Bottom bar
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
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(blurRadius: 8, offset: Offset(0, 3), color: Color(0x14000000)),
        ],
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปสินค้า
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SimpleSmartImageWidget(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                        errorWidget: const Center(
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.92),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        onPressed: () {}, // toggle favorite ได้ภายหลัง
                        icon: const Icon(Icons.favorite_border),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ชื่อสินค้า
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),

            // ราคา + ปุ่มตะกร้า
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '฿${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    // เพิ่มสินค้าเข้าตะกร้าแล้วเด้งไปหน้า /cart
                    cartStore.add(
                      title: product.name,
                      price: product.price,
                      image: product.image,
                      qty: 1,
                    );
                    Navigator.pushNamed(context, '/cart');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom bar
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
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
                        if (showBadge)
                          Positioned(
                            right: -10,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('84',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    const Text('ตะกร้า', style: TextStyle(color: Colors.white, fontSize: 11)),
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

