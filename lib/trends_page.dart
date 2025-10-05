import 'package:flutter/material.dart';

class TrendsPage extends StatelessWidget {
  const TrendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,

      // FAB “เทรนด์” ตรงกลาง เหมือนหน้าอื่น
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () {}, // อยู่หน้าเทรนด์แล้ว ไม่ต้องทำอะไร
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

      body: CustomScrollView(
        slivers: [
          // ── เฮดเดอร์ไล่เฉดม่วง + ช่องค้นหา + สินค้าเทรนด์แนวนอน ──
          const SliverToBoxAdapter(child: _TrendsHeader()),

          // (ลบชิปเมนูออกแล้ว)

          // ── ร้าน/แบรนด์ ที่กำลังมา ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Text(
                'ร้านฮิตติดเทรนด์',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Sweetra → ใช้ราคาให้ตรงกับหน้าอื่น
          const SliverToBoxAdapter(
            child: _ShopSection(
              title: 'กำลังมาแรง',
              images: [
                'assets/images/stylish/stylish01.jpg', // 250
                'assets/images/feelfree/feelfree02.jpg', // 319
                'assets/images/unigam/uni02.jpg',        // 299
                'assets/images/feelfree/feelfree03.jpg', // 309
              ],
              prices: [250, 319, 299, 309],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // ROMWE → ใช้ราคาให้ตรงกับหน้าอื่น
          const SliverToBoxAdapter(
            child: _ShopSection(
              title: 'กำลังมาแรง',
              images: [
                'assets/images/unigam/uni03.jpg', // 329
                'assets/images/duex/duex01.jpg',  // 299
                'assets/images/stylish/stylish01.jpg', // 250
                'assets/images/unigam/uni01.jpg', // 299
              ],
              prices: [329, 299, 250, 299],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),

      // ── แถบนำทางล่างแบบ BottomAppBar + ร่องสำหรับ FAB ──
      bottomNavigationBar: _BottomBar(
        showBadge: false,
        onTapHome: () => Navigator.pushNamed(context, '/'),
        onTapSearch: () => Navigator.pushNamed(context, '/products'),
        onTapCart: () => Navigator.pushNamed(context, '/cart'),
        onTapUser: () => Navigator.pushNamed(context, '/login'),
      ),
    );
  }
}

/// ───────────────── Header ม่วง + ค้นหา + สินค้าเทรนด์แนวนอน ─────────────────
class _TrendsHeader extends StatelessWidget {
  const _TrendsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB296FF), Color(0xFF7B57FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SearchFieldTrends(),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Text(
                    '#ซัมเมอร์เกิร์ลส์',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.open_in_new_rounded, color: Colors.white, size: 18),
                ],
              ),
              const SizedBox(height: 10),
              // สินค้าเทรนด์แนวนอน (อัปเดตราคาให้ตรงกับหน้าอื่นแล้ว)
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _trendItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _TrendCard(item: _trendItems[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchFieldTrends extends StatelessWidget {
  const _SearchFieldTrends();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white70, width: 1.2),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'กำลังฮิตอะไรอยู่…',
          hintStyle: TextStyle(color: Colors.black54),
          prefixIcon: Icon(Icons.search, color: Colors.black87, size: 15),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 8),
        ),
      ),
    );
  }
}

/// ข้อมูลสินค้าเทรนด์ (ราคาตรงกับหน้าอื่น)
class _TrendItem {
  final String image;
  final String title;
  final int price;
  const _TrendItem(this.image, this.title, this.price);
}

const _trendItems = <_TrendItem>[
  _TrendItem('assets/images/stylish/stylish01.jpg', 'เดรส', 250),
  _TrendItem('assets/images/feelfree/feelfree03.jpg', 'เดรสลายจุด', 309),
  _TrendItem('assets/images/unigam/uni03.jpg', 'กางเกงลาย', 329),
  _TrendItem('assets/images/unigam/uni01.jpg', 'เสื้อยืดลายทาง', 299),
];

class _TrendCard extends StatelessWidget {
  final _TrendItem item;
  const _TrendCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x20000000), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              item.image,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFFEFEFEF)),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '฿${item.price}',
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ───────────────── Section ร้าน/แบรนด์ ─────────────────
class _ShopSection extends StatelessWidget {
  final String title;
  final List<String> images;
  final List<int> prices;
  const _ShopSection({
    required this.title,
    required this.images,
    required this.prices,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ชื่อร้าน + ปุ่ม "กำลังติด…"
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text('กำลังติด…'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black87,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, i) =>
                _ShopImageTile(image: images[i], price: prices[i]),
          ),
        ],
      ),
    );
  }
}

class _ShopImageTile extends StatelessWidget {
  final String image;
  final int price;
  const _ShopImageTile({required this.image, required this.price});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFFEFEFEF)),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '฿$price',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ───────────────── Bottom bar (เหมือนหน้า Home/Products) ─────────────────
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

            const SizedBox(width: 48), // ช่องเว้นให้ FAB กลาง

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
                        const Icon(Icons.shopping_cart_outlined,
                            color: Colors.white, size: 22),
                        if (showBadge)
                          Positioned(
                            right: -10,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '84',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    const Text('ตะกร้า',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
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
