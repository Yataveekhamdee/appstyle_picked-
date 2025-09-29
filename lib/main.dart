import 'package:flutter/material.dart';

// เพิ่ม imports ของหน้าต่าง ๆ ให้ครบ
import '../login_page.dart';
import '../signup_page.dart';
import '../change_password_page.dart';
import '../product_list_page.dart';
import '../stylish_list_page.dart';
import '../duex_list_page.dart';
import '../cintage_list_page.dart';
import '../unigam_list_page.dart';
import '../checkout_page.dart';
import '../payment_detail_page.dart';
import 'cart_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Style Picked',

      // ❗บังคับโหมดสว่าง ไม่ตามเครื่อง
      themeMode: ThemeMode.light,

      // 🎨 กำหนดธีมให้พื้นเป็นขาว ตัวอักษรดำ และปิดการ tint
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ).copyWith(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black87,
          background: Colors.white,
          onBackground: Colors.black87,
          error: Colors.red,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,

        // ปิดการ tint ของผิวต่างๆ
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: const CardTheme(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          shadowColor: Color(0x14000000),
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),

        // ทำให้ NavigationBar เป็นพื้นดำ ตัวอักษร/ไอคอนขาว
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.black,
          indicatorColor: Colors.white10,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          iconTheme: MaterialStatePropertyAll(IconThemeData(color: Colors.white)),
          labelTextStyle: MaterialStatePropertyAll(TextStyle(color: Colors.white)),
        ),

        // ปุ่มหลักเป็นดำ-ขาวให้ตรงกับดีไซน์
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
      ),

      home: const HomePage(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignUpPage(),
        '/forgot': (_) => const ChangePasswordPage(),
        '/products': (_) => const ProductListPage(),
        '/stylish': (_) => const StylishListPage(),
        '/duex': (_) => const DuexListPage(),
        '/cintage': (_) => const CintageListPage(),
        '/unigam': (_) => const UnigamListPage(),
        '/checkout': (_) => const CheckoutPage(),
        '/paymentDetail': (_) => const PaymentDetailPage(),
        '/cart': (_) => const CartPage()
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

  final highlightCtrl = PageController(viewportFraction: .42);
  int highlightIndex = 0;

  // ✅ filter chips
  final filters = const ['See All', 'stylish', 'duex', 'cintage', 'unigam'];

  final banners = const [
    'https://cdn.prod.website-files.com/619cb4782095e30d37ddc385/67b3132fe42d36d7e2292be0_how-tom-make-clothes-always-smell-good-p-500.jpg',
    'https://cdn.prod.website-files.com/619cb4782095e30d37ddc385/64a983eed92cf06a0089ba42_how-to-start-your-own-tshirt-business-p-1080.jpg',
  ];

  // ✅ ใช้รูปจาก assets ที่มีอยู่จริง (ราคาเป็น double)
  final items = const [
    ProductItem(
      title: 'duex',
      price: 250.0,
      image: 'assets/images/duex/duex00.jpg',
    ),
    ProductItem(
      title: 'stylish',
      price: 257.0,
      image: 'assets/images/stylish/stylish00.jpg',
    ),
    ProductItem(
      title: 'unigam',
      price: 238.0,
      image: 'assets/images/unigam/uni00.jpg',
    ),
    ProductItem(
      title: 'duex',
      price: 269.0,
      image: 'assets/images/duex/duex01.jpg',
    ),
  ];

  @override
  void dispose() {
    bannerCtrl.dispose();
    highlightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // ให้เนื้อหาไหลใต้ bottomSheet ได้ลื่นขึ้น
      backgroundColor: Colors.white,

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // แถวเมนู + ค้นหา + ตะกร้า
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Row(
                  children: [
                    _roundIcon(Icons.menu, onTap: () {}),
                    const SizedBox(width: 8),
                    Expanded(child: _SearchField()),
                    const SizedBox(width: 8),
                    _roundIcon(Icons.shopping_cart_outlined, onTap: () {}),
                  ],
                ),
              ),
            ),

            // ===== Filter chips =====
            SliverToBoxAdapter(
              child: SizedBox(
                height: 42,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) => _FilterChip(
                    text: filters[i],
                    // 👉 ไม่ไฮไลต์ See All: ใช้สีปกติทุกตัว
                    selected: false,
                    onSelected: (_) {
                      final f = filters[i];
                      if (f == 'See All') {
                        Navigator.pushNamed(context, '/products');
                      } else if (f == 'stylish') {
                        Navigator.pushNamed(context, '/stylish');
                      } else if (f == 'duex') {
                        Navigator.pushNamed(context, '/duex');
                      } else if (f == 'cintage') {
                        Navigator.pushNamed(context, '/cintage');
                      } else if (f == 'unigam') {
                        Navigator.pushNamed(context, '/unigam');
                      }
                    },
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: filters.length,
                ),
              ),
            ),

            // ===== Banner =====
            SliverToBoxAdapter(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: bannerCtrl,
                      onPageChanged: (i) => setState(() => bannerIndex = i),
                      itemCount: banners.length,
                      itemBuilder: (_, i) => _RoundedImage(url: banners[i]),
                    ),
                    const Center(
                      child: Text(
                        'Get your own clothes\nand style!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                        ),
                      ),
                    ),
                    Positioned(right: 14, top: 12, child: _ghostBtn('More  >', () {})),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: _Dots(count: banners.length, active: bannerIndex),
                    )
                  ],
                ),
              ),
            ),

            // ===== Brands (โชว์รูปแรกของแต่ละแบรนด์) =====
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

            // ===== Newest + ... =====
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Row(
                  children: [
                    _StripTitle(text: 'Newest!'),
                    Spacer(),
                    _Kebab(),
                  ],
                ),
              ),
            ),

            // ===== Coming soon =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      const _RoundedImage(
                        url:
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRd2tp-BQKzegwNcU0k1YQ2P8YTk-6CIH-yRQ&s',
                      ),
                      const Center(
                        child: Text(
                          'Coming Soon',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IconButton.filled(
                          onPressed: () {},
                          icon: const Icon(Icons.arrow_forward_ios, size: 18),
                          style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(Colors.white70),
                            foregroundColor: MaterialStatePropertyAll(Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // เผื่อพื้นที่ไม่ให้เนื้อหาโดนปุ่มเข้าสู่ระบบที่เป็น bottomSheet บัง
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      // แผงปุ่มเข้าสู่ระบบติดขอบล่าง
      bottomSheet: _LoginBottomBar(
        onTap: () => Navigator.pushNamed(context, '/login'),
      ),

      // ===== bottom nav (นำทางได้จริง) =====
      bottomNavigationBar: NavigationBar(
        height: 68,
        backgroundColor: Colors.black,
        indicatorColor: Colors.white10,
        selectedIndex: 0, // หน้านี้เป็น Home
        onDestinationSelected: (index) {
          if (index == 0) {
            // อยู่หน้า Home แล้ว
          } else if (index == 1) {
            Navigator.pushNamed(context, '/products');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/products'); // ใช้ /products แทน Search ชั่วคราว
          } else if (index == 3) {
            Navigator.pushNamed(context, '/login');
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

/// ===== components =====
class _SearchField extends StatelessWidget {
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

class _FilterChip extends StatelessWidget {
  final String text;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  const _FilterChip({required this.text, this.selected = false, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(text),
      selected: selected,
      onSelected: onSelected,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w700,
      ),
      selectedColor: Colors.black,
      backgroundColor: const Color(0xFFEFEFEF),
      shape: const StadiumBorder(),
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

class _Kebab extends StatelessWidget {
  const _Kebab();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: const Padding(
        padding: EdgeInsets.all(6.0),
        child: Icon(Icons.more_vert, color: Colors.black87),
      ),
    );
  }
}

class ProductItem {
  final String title;
  final double price;
  final String image; // asset path หรือ http
  const ProductItem({required this.title, required this.price, required this.image});
}

class _ProductCardWide extends StatelessWidget {
  final ProductItem item;
  const _ProductCardWide({required this.item});

  @override
  Widget build(BuildContext context) {
    final isNet = item.image.startsWith('http');
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(blurRadius: 8, offset: Offset(0, 3), color: Color(0x14000000))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: isNet
                          ? Image.network(item.image, fit: BoxFit.cover)
                          : Image.asset(item.image, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(.9), shape: BoxShape.circle),
                        child: IconButton(
                          constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  Expanded(child: Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '${item.price.toStringAsFixed(0)}.-  ฿',
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w800),
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

// ===== กริดปุ่มเข้า 4 หน้าแบรนด์ (ใช้รูปแรกของแต่ละแบรนด์) =====
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
          label: 'cintage',
          route: '/cintage',
          asset: 'assets/images/cintage/cintage00.jpg',
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

// ✅ การ์ดแบรนด์แบบใช้รูปแรกของแต่ละแบรนด์ + กดแล้วไปหน้าแบรนด์
class _BrandCardImage extends StatelessWidget {
  final String label; // ชื่อแบรนด์
  final String route; // เส้นทางไปหน้าแบรนด์
  final String asset; // รูปแรกของแบรนด์ (assets path)

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
              // รูปพื้นหลังของแบรนด์
              Image.asset(
                asset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Color(0xFFEFEFEF)),
              ),

              // แผงไล่แสง + ชื่อแบรนด์ด้านล่าง
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              // ไอคอนมุมขวาบน
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.92),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.favorite_border, size: 16),
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

// ===== bottom sheet ปุ่มเข้าสู่ระบบ (สไตล์โปร่งดำ + ปุ่มขาวขวา) =====
class _LoginBottomBar extends StatelessWidget {
  final VoidCallback onTap;
  final String message;
  const _LoginBottomBar({
    super.key,
    required this.onTap,
    this.message = 'ลงชื่อเข้าใช้เพื่อช้อปสะดวกขึ้น',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.65), // พื้นหลังโปร่งดำ
          border: const Border(
            top: BorderSide(color: Color(0x33FFFFFF), width: .6), // เส้นขาวจางด้านบน
          ),
        ),
        child: Row(
          children: [
            // ข้อความฝั่งซ้าย (สีขาว)
            Expanded(
              child: Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // ปุ่มขาวขอบมนฝั่งขวา
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 0,
                ),
                child: const Text(
                  'ลงชื่อเข้าใช้',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Widget _ghostBtn(String label, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white70, width: .7),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    ),
  );
}
