// lib/pages/product/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/cart_store.dart';
import '../../models/product_model.dart';
import '../../widgets/simple_network_image_widget.dart';
import 'product_reviews_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});
  @override
  State<ProductListPage> createState() => _ProductListState();
}

class _ProductListState extends State<ProductListPage> {
  final _search = TextEditingController();
  String? _catId;

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลครั้งเดียวหลัง build แรก
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProductProvider>();
    final cp = context.watch<CategoryProvider>();

    // กรองจาก keyword + หมวดหมู่
    final kw = _search.text.trim().toLowerCase();
    final items = pp.products.where((p) {
      final hitKw = kw.isEmpty ||
          p.name.toLowerCase().contains(kw) ||
          (p.categoryName ?? '').toLowerCase().contains(kw);
      final hitCat = _catId == null || p.categoryId == _catId;
      return hitKw && hitCat;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'ค้นหาสินค้า/หมวดหมู่…',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── แถบหมวดหมู่ ───────────────────────────
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                ChoiceChip(
                  label: const Text('ทั้งหมด'),
                  selected: _catId == null,
                  onSelected: (_) => setState(() => _catId = null),
                ),
                for (final c in cp.activeCategories) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(c.name),
                    selected: _catId == c.id,
                    onSelected: (_) => setState(() => _catId = c.id),
                  ),
                ],
              ],
            ),
          ),

          // ── กริดสินค้า ─────────────────────────────
          Expanded(
            child: LayoutBuilder(
              builder: (_, cons) {
                final w = cons.maxWidth;
                final cols = w >= 900 ? 4 : (w >= 600 ? 3 : 2);
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: .66,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _ProductCard(p: items[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* ======================= UI: การ์ดสินค้า (สั้น/อ่านง่าย) ======================= */

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.p});
  final Product p;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูป + ราคา + ปุ่มเพิ่มตะกร้า
          AspectRatio(
            aspectRatio: 1,
            child: Stack(fit: StackFit.expand, children: [
              SimpleNetworkImageWidget(imageUrl: p.image, fit: BoxFit.cover),

              // ป้ายราคา
              Positioned(
                left: 10,
                bottom: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text('฿${_fmt(p.price)}',
                        style: TextStyle(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),

              // ปุ่มเพิ่มตะกร้า
              Positioned(
                right: 10,
                bottom: 10,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    cartStore.add(
                      productId: p.id,
                      title: p.name,
                      price: p.price,
                      image: p.image,
                      qty: 1,
                    );
                    Navigator.pushNamed(context, '/cart');
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: cs.primary, shape: BoxShape.circle),
                    child: Icon(Icons.add_shopping_cart,
                        color: cs.onPrimary, size: 18),
                  ),
                ),
              ),
            ]),
          ),

          // ชื่อ + หมวด + ปุ่มรีวิว
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
            child: Text(
              p.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(children: [
              Expanded(
                child: Text(
                  p.categoryName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.rate_review_outlined, size: 16),
                label: const Text('รีวิว'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProductReviewsPage(productId: p.id)),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

/* =============================== Helpers =============================== */

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
