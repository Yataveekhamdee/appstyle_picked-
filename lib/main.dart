import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// pages
import 'pages/auth/login_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/auth/account_page.dart';

import 'pages/products/product_list_page.dart';
import 'pages/products/product_detail_page.dart';
import 'pages/products/stylish_list_page.dart';
import 'pages/products/duex_list_page.dart';
import 'pages/products/feelfree_list_page.dart';
import 'pages/products/unigam_list_page.dart';
import 'pages/products/trends_page.dart';

import 'pages/cart/cart_page.dart';
import 'pages/cart/checkout_page.dart';
import 'pages/cart/order_preparing_page.dart';
import 'pages/cart/payment_detail_page.dart';

import 'pages/address/address_form_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Style Picked',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.black).copyWith(primary: Colors.black),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const HomePage(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/products': (_) => const ProductListPage(),
        '/stylish': (_) => const StylishListPage(),
        '/duex': (_) => const DuexListPage(),
        '/feelfree': (_) => const FeelFreeListPage(),
        '/unigam': (_) => const UnigamListPage(),
        '/checkout': (_) => const CheckoutPage(),
        '/paymentDetail': (_) => const PaymentDetailPage(),
        '/cart': (_) => const CartPage(),
        '/trends': (_) => const TrendsPage(),
        '/address': (_) => const AddressFormPage(),
        '/orderPreparing': (_) => const OrderPreparingPage(),
        '/account': (_) => const AccountPage(),
        // '/productDetail': (_) => const ProductDetailPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final bannerCtrl = PageController();
  int bannerIndex = 0;

  // ฟิลเตอร์ใต้ช่องค้นหา
  final _filters = const ['See All', 'stylish', 'duex', 'feelfree', 'unigam'];

  @override
  void dispose() {
    bannerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      // ===== FAB "เทรนด์" วงกลม =====
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
        child: CustomScrollView(
          slivers: [
            // แถวค้นหา + ตะกร้า
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Row(
                  children: [
                    const SizedBox(width: 2),
                    const Expanded(child: _SearchField()),
                    const SizedBox(width: 8),
                    _roundIcon(
                      Icons.shopping_cart_outlined,
                      onTap: () => Navigator.pushNamed(context, '/cart'),
                    ),
                  ],
                ),
              ),
            ),

            // ===== ปุ่มฟิลเตอร์ =====
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                child: Row(
                  children: [
                    _FilterPill(
                      label: _filters[0],
                      selected: true,
                      onTap: () => Navigator.pushNamed(context, '/products'),
                    ),
                    const SizedBox(width: 8),
                    _FilterPill(
                        label: 'stylish',
                        onTap: () => Navigator.pushNamed(context, '/stylish')),
                    const SizedBox(width: 8),
                    _FilterPill(
                        label: 'duex', onTap: () => Navigator.pushNamed(context, '/duex')),
                    const SizedBox(width: 8),
                    _FilterPill(
                        label: 'feelfree',
                        onTap: () => Navigator.pushNamed(context, '/feelfree')),
                    const SizedBox(width: 8),
                    _FilterPill(
                        label: 'unigam',
                        onTap: () => Navigator.pushNamed(context, '/unigam')),
                  ],
                ),
              ),
            ),

            // ===== พรีวิวด้านบนสุด =====
            SliverToBoxAdapter(
              child: TopPreviewSimple(
                bg: 'assets/images/unigam/uni04.jpg',
                left: MiniItem('assets/images/duex/duex01.jpg', 299),
                right: MiniItem('assets/images/feelfree/feelfree03.jpg', 309),
                onMore: () {},
              ),
            ),

            // ===== แถบโปรโมชัน =====
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: _PromoStrip(),
              ),
            ),

            // ===== Brands (4 การ์ด) =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _StripTitle(text: 'Brands'),
                    SizedBox(height: 10),
                    _BrandGrid(),
                  ],
                ),
              ),
            ),

            // ===== รูปเสื้อจาก assets ใต้แบรนด์ =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: const [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image(
                          image: AssetImage('assets/images/unigam/uni04.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            'Get your own clothes\nand style!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        ),
      ),

      // ===== Bottom bar =====
      bottomNavigationBar: _BottomBar(
        showBadge: false,
        onTapHome: () {},
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

/// ===== components =====

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

/// ปุ่มฟิลเตอร์ทรงกลมรี
class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _FilterPill({required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final borderColor = const Color(0xFF6B5B5B);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? Colors.black : borderColor,
            width: selected ? 2 : 1.4,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _RoundedImage extends StatelessWidget {
  final String url;
  const _RoundedImage({required this.url});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int active;
  const _Dots({required this.count, required this.active});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 6,
          width: i == active ? 16 : 6,
          decoration: BoxDecoration(
            color: i == active ? Colors.black : Colors.black26,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// ───────── กริดแบรนด์ 4 ภาพ ─────────
class _BrandGrid extends StatelessWidget {
  const _BrandGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: const [
        _BrandCardImage(
          label: 'stylish',
          route: '/stylish',
          asset: 'assets/images/stylish/stylish00.jpg',
        ),
        _BrandCardImage(
          label: 'duex',
          route: '/duex',
          asset: 'assets/images/duex/duex00.jpg',
        ),
        _BrandCardImage(
          label: 'feelfree',
          route: '/feelfree',
          asset: 'assets/images/feelfree/feelfree00.jpg',
        ),
        _BrandCardImage(
          label: 'unigam',
          route: '/unigam',
          asset: 'assets/images/unigam/uni00.jpg',
        ),
      ],
    );
  }
}

class _BrandCardImage extends StatelessWidget {
  final String label;
  final String route;
  final String asset;

  const _BrandCardImage({
    super.key,
    required this.label,
    required this.route,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                asset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFEFEFEF)),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xB3000000), Color(0x33000000), Colors.transparent],
                    ),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StripTitle extends StatelessWidget {
  final String text;
  const _StripTitle({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
    );
  }
}

class _PromoStrip extends StatelessWidget {
  const _PromoStrip();

  static const bg = Color(0xFFFFF5E8);
  static const border = Color(0xFFE9DCCB);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: const [
          _PromoItem(
            icon: Icons.check,
            iconColor: Colors.brown,
            title: 'จัดส่งฟรี',
            subtitle: 'เมื่อซื้อครบ 290.-',
          ),
          VerticalDivider(width: 24, color: border, thickness: 1),
          _PromoItem(
            icon: Icons.inventory_2_outlined,
            iconColor: Colors.brown,
            title: 'ซื้อครบ 500',
            subtitle: 'แถมกำไลข้อมือ',
          ),
        ],
      ),
    );
  }
}

class _PromoItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _PromoItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.brown)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 11, height: 1.1, color: Colors.brown)),
            ],
          ),
        ],
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

            const SizedBox(width: 48),

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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

/// ───────── พรีวิวบนสุด ─────────
class MiniItem {
  final String asset;
  final int price;
  const MiniItem(this.asset, this.price);
}

class TopPreviewSimple extends StatelessWidget {
  final String bg;
  final MiniItem left;
  final MiniItem right;
  final VoidCallback? onMore;

  const TopPreviewSimple({
    super.key,
    required this.bg,
    required this.left,
    required this.right,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Positioned.fill(child: Image.asset(bg, fit: BoxFit.cover)),
          Positioned.fill(child: ColoredBox(color: Colors.black.withOpacity(.18))),
          const Positioned(left: 18, top: 12, child: _TrendsHead()),
          Positioned(
            right: 16,
            top: 26,
            child: Row(
              children: [
                _MiniCard(item: left),
                const SizedBox(width: 12),
                _MiniCard(item: right),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final MiniItem item;
  const _MiniCard({required this.item});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 160,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDD1FF), width: 3),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(item.asset, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            left: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 4)],
              ),
              child: Text('฿${item.price}',
                  style: const TextStyle(color: Color(0xFFE55A00), fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendsHead extends StatelessWidget {
  const _TrendsHead();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _TrendsTag(),
        SizedBox(height: 5),
        Text(
          'สินค้าขายดี',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
          ),
        ),
      ],
    );
  }
}

class _TrendsTag extends StatelessWidget {
  const _TrendsTag();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.trending_up, size: 18, color: Color(0xFF6C4CFF)),
          SizedBox(width: 6),
          Text('trends',
              style:
                  TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6C4CFF))),
        ],
      ),
    );
  }
}
