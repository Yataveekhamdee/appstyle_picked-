import 'package:flutter/material.dart';
import 'cart_store.dart';

/// ---- โมเดลสินค้า ----
class Product {
  final String id;
  final String title;
  final double price;
  final String image;
  final String brand;
  final String? description;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.brand,
    this.description,
  });

  /// เผื่อบางหน้าส่งมาเป็น Map ก็รองรับ
  factory Product.fromArgs(dynamic a) {
    if (a is Product) return a;
    if (a is Map) {
      return Product(
        id: a['id'] ?? a['sku'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: (a['title'] ?? a['name'] ?? 'สินค้า').toString(),
        price: (a['price'] as num?)?.toDouble() ?? 0,
        image: (a['image'] ?? a['img'] ?? '').toString(),
        brand: (a['brand'] ?? 'brand').toString(),
        description: a['desc']?.toString(),
      );
    }
    throw ArgumentError('ProductDetailPage: arguments ไม่ถูกต้อง');
  }
}

/// ---- รีวิว + Store แบบ in-memory ----
class Review {
  final String name;
  final int rating; // 1..5
  final String comment;
  final DateTime createdAt;
  Review(this.name, this.rating, this.comment) : createdAt = DateTime.now();
}

class ReviewStore {
  static final Map<String, List<Review>> _db = {};
  static List<Review> list(String productId) => _db[productId] ??= [];
  static void add(String productId, Review r) => list(productId).add(r);
}

/// ---- หน้ารายละเอียด + รีวิว (ใช้ร่วมทุกแบรนด์) ----
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final Product product;

  final _nameCtl = TextEditingController();
  final _commentCtl = TextEditingController();
  int _rating = 5;

  List<Review> get _reviews => ReviewStore.list(product.id);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _commentCtl.dispose();
    super.dispose();
  }

  void _addToCart() {
    cartStore.add(
      title: product.title,
      price: product.price,
      image: product.image,
      qty: 1,
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('เพิ่มลงตะกร้าแล้ว')));
  }

  void _submitReview() {
    final name = _nameCtl.text.trim().isEmpty ? 'ผู้ซื้อ' : _nameCtl.text.trim();
    final text = _commentCtl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('พิมพ์ความเห็นก่อน')));
      return;
    }
    setState(() {
      ReviewStore.add(product.id, Review(name, _rating, text));
      _nameCtl.clear();
      _commentCtl.clear();
      _rating = 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    // รับ arguments จาก Navigator
    product = Product.fromArgs(ModalRoute.of(context)?.settings.arguments);

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
              child: Image.asset(
                product.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Color(0xFFEFEFEF)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ชื่อ + ราคา + ปุ่มตะกร้า
          Text(product.title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('฿${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.w900)),
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

          // รายละเอียด
          Container(
            padding: const EdgeInsets.all(12),
            decoration: _box(),
            child: Text(
              product.description ??
                  'รายละเอียดสินค้า\n'
                  '- เนื้อผ้านุ่ม ระบายอากาศดี\n'
                  '- งานตัดเย็บประณีต\n'
                  '- ซักเครื่องได้ แห้งไว',
              style: const TextStyle(height: 1.4),
            ),
          ),

          const SizedBox(height: 16),
          const Text('รีวิวจากลูกค้า',
              style: TextStyle(fontWeight: FontWeight.w900)),

          const SizedBox(height: 6),
          if (_reviews.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: _box(),
              child: const Text('ยังไม่มีรีวิว เป็นคนแรกที่รีวิวสินค้านี้เลย!'),
            )
          else
            ..._reviews.map(
              (r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: _box(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                        radius: 16, child: Icon(Icons.person, size: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(r.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            _Stars(r.rating),
                            const Spacer(),
                            Text(_fmt(r.createdAt),
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black54)),
                          ]),
                          const SizedBox(height: 4),
                          Text(r.comment),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 14),
          const Text('เขียนรีวิวของคุณ',
              style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),

          // ฟอร์มรีวิว
          Container(
            padding: const EdgeInsets.all(12),
            decoration: _box(),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                decoration:
                    const InputDecoration(labelText: 'เขียนความเห็นของคุณ...'),
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
          icon: Icon(n <= value ? Icons.star : Icons.star_border,
              color: Colors.amber),
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
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star : Icons.star_border,
          size: 14,
          color: Colors.amber,
        ),
      ),
    );
  }
}
