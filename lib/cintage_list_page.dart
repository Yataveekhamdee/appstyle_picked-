import 'package:flutter/material.dart';

class CintageListPage extends StatelessWidget {
  const CintageListPage({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _CT('Cintage 01', 299,  'assets/images/cintage/cintage01.jpg'),
      _CT('Cintage 02', 319,  'assets/images/cintage/cintage02.jpg'),
      _CT('Cintage 03', 309, 'assets/images/cintage/cintage03.jpg'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cintage', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 14.0,
            childAspectRatio: .76,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => _ProductCard(item: items[i]),
        ),
      ),

      // ✅ NavBar ล่าง เหมือน 3 หน้าก่อน
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
}

class _CT {
  final String title;
  final double price;
  final String image;
  const _CT(this.title, this.price, this.image);
}

class _ProductCard extends StatelessWidget {
  final _CT item;
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
        border: Border.all(color: Color(0xFFF0F0F0)),
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
                        gaplessPlayback: true,
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
                        onPressed: () {}, // favorite ไว้ต่อภายหลัง
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

            // ราคา + ปุ่มตะกร้า (โชว์ไว้ แต่ไม่ทำงานตามสเปค)
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
                    // ไม่ทำอะไร (ไม่ไป checkout)
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
