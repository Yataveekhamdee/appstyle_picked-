import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget gap(double h) => SizedBox(height: h);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Style Picked '),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          
          IconButton(
          icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/admin/login'),
          )

        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _banner('assets/images/unigam/uni04.jpg', 'สินค้าแนะนำ'),
          gap(12),
          Row(children: [
            _promo(cs, Icons.local_shipping_outlined, 'จัดส่งฟรี', 'ส่งของภายใน'),
            const SizedBox(width: 12),
            _promo(cs, Icons.card_giftcard_outlined, 'ครบ 500.-', 'แถมสร้อยคอ'),
          ]),
          gap(16),
          const Text('Brands', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          gap(10),

          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _BrandCard('Duex',     'assets/images/duex/duex00.jpg'),
              _BrandCard('Feelfree', 'assets/images/feelfree/feelfree00.jpg'),
              _BrandCard('Stylist',  'assets/images/stylish/stylish00.jpg'),
              _BrandCard('Unigam',   'assets/images/unigam/uni00.jpg'),
            ],
          ),
          gap(16),
          _banner('assets/images/unigam/uni04.jpg', 'Get your own clothes\nand style!'),
          gap(24),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 58,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 'หน้าหลัก', () {}),
            _navItem(Icons.search, 'หมวดหมู่', () => Navigator.pushNamed(context, '/products')),
            _navItem(Icons.shopping_cart_outlined, 'ตะกร้า', () => Navigator.pushNamed(context, '/cart')),
            _navItem(Icons.person_outline, 'ฉัน', () => Navigator.pushNamed(context, '/profile')),

          ],
        ),
      ),
    );
  }

  static Widget _banner(String asset, String text) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(asset, height: 160, width: double.infinity, fit: BoxFit.cover),
            Container(height: 160, color: Colors.black26),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                )),
          ],
        ),
      );

  static Widget _promo(ColorScheme cs, IconData icon, String t, String s) => Expanded(
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: cs.secondaryContainer.withOpacity(.25),
            border: Border.all(color: cs.secondaryContainer),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            const SizedBox(width: 2),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(s, style: const TextStyle(fontSize: 11, height: 1.1)),
              ],
            ),
          ]),
        ),
      );

  static Widget _navItem(IconData i, String t, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 72,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(i, size: 22),
            const SizedBox(height: 2),
            Text(t, style: const TextStyle(fontSize: 11)),
          ]),
        ),
      );
}

class _BrandCard extends StatelessWidget {
  const _BrandCard(this.title, this.imagePath, {this.onTap});
  final String title, imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.primary, width: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            const Align(
              alignment: Alignment.bottomCenter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xB3000000), Color(0x33000000), Colors.transparent],
                  ),
                ),
                child: SizedBox.expand(),
              ),
            ),
            Positioned(
              left: 10, right: 10, bottom: 8,
              child: Text(title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
      ),
    );
  }
}
