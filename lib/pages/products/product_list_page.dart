import 'package:flutter/material.dart';
import '../../providers/cart_store.dart';
import '../../services/firestore_service.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // รายชื่อแบรนด์ (แท็บฝั่งซ้าย)
  final filters = const ['See All', 'stylish', 'duex', 'feelfree', 'unigam'];
  int selected = 0;

  // สินค้าทั้งหมด
  static const List<_PL> _allItems = [
    _PL('Stylish 01', 250, 'assets/images/stylish/stylish01.jpg', 'stylish'),
    _PL('Duex 01', 299, 'assets/images/duex/duex01.jpg', 'duex'),
    _PL('feelfree 01', 299, 'assets/images/feelfree/feelfree01.jpg', 'feelfree'),
    _PL('feelfree 02', 319, 'assets/images/feelfree/feelfree02.jpg', 'feelfree'),
    _PL('feelfree 03', 309, 'assets/images/feelfree/feelfree03.jpg', 'feelfree'),
    _PL('Unigam 01', 299, 'assets/images/unigam/uni01.jpg', 'unigam'),
    _PL('Unigam 02', 299, 'assets/images/unigam/uni02.jpg', 'unigam'),
    _PL('Unigam 03', 329, 'assets/images/unigam/uni03.jpg', 'unigam'),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleItems = selected == 0
        ? _allItems
        : _allItems.where((e) => e.brand == filters[selected]).toList();

    // กำหนดจำนวนคอลัมน์ตามความกว้างหน้าจอ
    final width = MediaQuery.of(context).size.width;
    final cols = width >= 900 ? 4 : width >= 600 ? 3 : 2;

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
                          onTap: () => setState(() => selected = i),
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
                      itemBuilder: (_, i) => _ProductCard(item: visibleItems[i]),
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

/// ===== Model =====
class _PL {
  final String title;
  final double price;
  final String image; // asset path
  final String brand; // stylish | duex | feelfree | unigam
  const _PL(this.title, this.price, this.image, this.brand);
}

/// ===== Card สินค้า =====
class _ProductCard extends StatelessWidget {
  final _PL item;
  const _ProductCard({required this.item});

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
                    child: Image.asset(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.image_not_supported_outlined)),
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
                          title: item.title,
                          price: item.price,
                          image: item.image,
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
                  Text(item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '฿${item.price.toStringAsFixed(0)}',
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
