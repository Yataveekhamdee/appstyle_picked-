import 'package:flutter/material.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // แก้สะกดให้ตรงกับชื่อหน้าอื่น ๆ
  final filters = const ['See All', 'stylish', 'duex', 'cintage', 'unigam'];
  int selected = 0;

  // รวมสินค้า 4 แบรนด์จาก assets (ใช้ชื่อ/ราคาให้ตรงกับแต่ละหน้า)
  static const List<_PL> _allItems = [
    // ---- Stylish (มีรูปอย่างน้อย 00-01) ----
    _PL('Stylish 01', 250, 'assets/images/stylish/stylish01.jpg', 'stylish'),

    // ---- Duex ----
    _PL('Duex 01', 299, 'assets/images/duex/duex01.jpg', 'duex'),

    // ---- Cintage ----
    _PL('Cintage 01', 299, 'assets/images/cintage/cintage01.jpg', 'cintage'),
    _PL('Cintage 02', 319, 'assets/images/cintage/cintage02.jpg', 'cintage'),
    _PL('Cintage 03', 309, 'assets/images/cintage/cintage03.jpg', 'cintage'),

    // ---- Unigam ----
    _PL('Unigam 01', 299, 'assets/images/unigam/uni01.jpg', 'unigam'),
    _PL('Unigam 02', 299, 'assets/images/unigam/uni02.jpg', 'unigam'),
    _PL('Unigam 03', 329, 'assets/images/unigam/uni03.jpg', 'unigam'),
  ];

  @override
  Widget build(BuildContext context) {
    // กรองตามฟิลเตอร์
    final visibleItems = selected == 0
        ? _allItems
        : _allItems.where((e) => e.brand == filters[selected]).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // แถวบนสุด
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Row(
                  children: [
                    _roundIcon(Icons.arrow_back, onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 8),
                    const Expanded(child: _SearchField()),
                    const SizedBox(width: 8),
                    _roundIcon(Icons.shopping_cart_outlined),
                  ],
                ),
              ),
            ),

            // ฟิลเตอร์แบรนด์
            SliverToBoxAdapter(
              child: SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filters.length,
                  itemBuilder: (_, i) => ChoiceChip(
                    label: Text(filters[i]),
                    selected: selected == i,
                    onSelected: (_) => setState(() => selected = i),
                    selectedColor: Colors.black,
                    backgroundColor: const Color(0xFFEFEFEF),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected == i ? Colors.white : Colors.black87,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                ),
              ),
            ),

            // กริดสินค้า — เลย์เอาต์เดียวกับหน้า Unigam
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 14.0,
                  childAspectRatio: .72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ProductCard(item: visibleItems[index]),
                  childCount: visibleItems.length,
                ),
              ),
            ),
          ],
        ),
      ),

      // bottom nav (เหมือนเดิม)
      bottomNavigationBar: NavigationBar(
        height: 68,
        backgroundColor: Colors.black,
        indicatorColor: Colors.white10,
        selectedIndex: 1, // หน้านี้เป็นหมวด Category
        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');          // Home
          } else if (index == 1) {
            Navigator.pushNamed(context, '/products');  // Category/All
          } else if (index == 2) {
            Navigator.pushNamed(context, '/products');  // ใช้ /products แทน Search ชั่วคราว
          } else if (index == 3) {
            Navigator.pushNamed(context, '/login');     // โปรไฟล์/ล็อกอิน
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.white),
            selectedIcon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined, color: Colors.white),
            selectedIcon: Icon(Icons.grid_view, color: Colors.white),
            label: 'Category',
          ),
          NavigationDestination(
            icon: Icon(Icons.search, color: Colors.white),
            selectedIcon: Icon(Icons.search, color: Colors.white),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: Colors.white),
            selectedIcon: Icon(Icons.person, color: Colors.white),
            label: 'user',
          ),
        ],
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

// ===== Model =====
class _PL {
  final String title;
  final double price;
  final String image; // asset path
  final String brand; // stylish | duex | cintage | unigam
  const _PL(this.title, this.price, this.image, this.brand);
}

// ===== Card แบบเดียวกับหน้า Unigam =====
class _ProductCard extends StatelessWidget {
  final _PL item;
  const _ProductCard({required this.item});

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
                      child: Image.asset(
                        item.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Icon(Icons.image_not_supported_outlined)),
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
              item.title,
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
                    '${item.price.toStringAsFixed(0)}.- ฿',
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
                    // ถ้าต้องการต่อเช็คเอาต์ในอนาคต: Navigator.pushNamed(context, '/checkout');
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
