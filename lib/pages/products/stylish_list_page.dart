import 'package:flutter/material.dart';
import '../../providers/cart_store.dart'; // ใช้ store เดียวกับตะกร้า

class StylishListPage extends StatelessWidget {
  const StylishListPage({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _SL('Stylish 01', 250, 'assets/images/stylish/stylish01.jpg'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Stylish', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),

      floatingActionButton: SizedBox(
        width: 64, height: 64,
        child: FloatingActionButton(
          onPressed: () {/* Navigator.pushNamed(context, '/trends'); */},
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

      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 14, childAspectRatio: .76,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => _ProductCard(item: items[i]),
        ),
      ),

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

class _SL {
  final String title;
  final double price;
  final String image;
  const _SL(this.title, this.price, this.image);
}

class _ProductCard extends StatelessWidget {
  final _SL item;
  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailPage(item: item)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(blurRadius: 8, offset: Offset(0, 3), color: Color(0x14000000))],
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // รูปสินค้า (เอาหัวใจออกแล้ว)
            Expanded(
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
            const SizedBox(height: 8),

            // ชื่อ
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),

            // ราคา + ปุ่ม
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '฿${item.price.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
                const Spacer(),
                // เพิ่มรถเข็น
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    cartStore.add(title: item.title, price: item.price, image: item.image, qty: 1);
                    Navigator.pushNamed(context, '/cart');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ปุ่มรายละเอียด
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetailPage(item: item)),
                ),
                child: const Text('รายละเอียด'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// หน้ารายละเอียด + รีวิวสินค้า
class ProductDetailPage extends StatefulWidget {
  final _SL item;
  const ProductDetailPage({super.key, required this.item});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _Review {
  final String name;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;
  _Review(this.name, this.rating, this.comment) : createdAt = DateTime.now();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // DB รีวิวแบบง่าย (อยู่ในหน่วยความจำแอประหว่างรัน)
  static final Map<String, List<_Review>> _reviewsDb = {};

  final _nameCtl = TextEditingController();
  final _commentCtl = TextEditingController();
  int _rating = 5;

  List<_Review> get _reviews => _reviewsDb[widget.item.title] ??= [];

  @override
  void dispose() {
    _nameCtl.dispose();
    _commentCtl.dispose();
    super.dispose();
  }

  void _addToCart() {
    cartStore.add(title: widget.item.title, price: widget.item.price, image: widget.item.image, qty: 1);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เพิ่มลงตะกร้าแล้ว')));
  }

  void _submitReview() {
    final name = _nameCtl.text.trim().isEmpty ? 'ผู้ซื้อ' : _nameCtl.text.trim();
    final comment = _commentCtl.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('พิมพ์ความเห็นก่อน')));
      return;
    }
    setState(() {
      _reviews.add(_Review(name, _rating, comment));
      _nameCtl.clear();
      _commentCtl.clear();
      _rating = 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดสินค้า', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
        children: [
          // รูปใหญ่
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(item.image, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFEFEFEF)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ชื่อ + ราคา + ปุ่มเพิ่มตะกร้า
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(999)),
                child: Text('฿${item.price.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('เพิ่มลงตะกร้า'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // รายละเอียด (ตัวอย่าง)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: _box(),
            child: const Text(
              'รายละเอียดสินค้า\n'
              '- เนื้อผ้านุ่ม ใส่สบาย ระบายอากาศดี\n'
              '- ทรงสวย เข้ารูป\n'
              '- ซักเครื่องได้ แห้งไว',
              style: TextStyle(height: 1.4),
            ),
          ),

          const SizedBox(height: 16),
          const Text('รีวิวจากลูกค้า', style: TextStyle(fontWeight: FontWeight.w900)),

          // รายการรีวิว
          const SizedBox(height: 6),
          if (_reviews.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: _box(),
              child: const Text('ยังไม่มีรีวิว เป็นคนแรกที่รีวิวสินค้านี้เลย!'),
            )
          else
            ..._reviews.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: _box(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(
                            children: [
                              Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(width: 8),
                              _Stars(r.rating),
                              const Spacer(),
                              Text(_fmt(r.createdAt), style: const TextStyle(fontSize: 11, color: Colors.black54)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(r.comment),
                        ]),
                      ),
                    ],
                  ),
                )),

          const SizedBox(height: 14),
          const Text('เขียนรีวิวของคุณ', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),

          // ฟอร์มรีวิว
          Container(
            padding: const EdgeInsets.all(12),
            decoration: _box(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                controller: _nameCtl,
                decoration: const InputDecoration(labelText: 'ชื่อ (ไม่บังคับ)'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('ให้คะแนน:  '),
                  _StarPicker(
                    value: _rating,
                    onChanged: (v) => setState(() => _rating = v),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentCtl,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'เขียนความเห็นของคุณ...'),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _submitReview,
                  child: const Text('ส่งรีวิว'),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  BoxDecoration _box() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      );

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _StarPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _StarPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 1;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: Icon(n <= value ? Icons.star : Icons.star_border, color: Colors.amber),
          onPressed: () => onChanged(n),
        );
      }),
    );
  }
}

class _Stars extends StatelessWidget {
  final int rating;
  const _Stars(this.rating);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) =>
          Icon(i < rating ? Icons.star : Icons.star_border, size: 14, color: Colors.amber)),
    );
  }
}

/// Bottom bar แบบหน้า main
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
      onTap: onTap, behavior: HitTestBehavior.opaque,
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
