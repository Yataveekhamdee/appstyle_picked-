// lib/pages/product/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/simple_network_image_widget.dart';
import '../../providers/cart_store.dart';
import 'product_reviews_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});
  @override
  State<ProductListPage> createState() => _State();
}

class _State extends State<ProductListPage> {
  final _search = TextEditingController();
  String? _catId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    final pp = ctx.watch<ProductProvider>();
    final cp = ctx.watch<CategoryProvider>();

    final kw = _search.text.trim().toLowerCase();
    final items = pp.products.where((p) {
      final byKw = kw.isEmpty ||
          p.name.toLowerCase().contains(kw) ||
          (p.categoryName ?? '').toLowerCase().contains(kw);
      final byCat = _catId == null || p.categoryId == _catId;
      return byKw && byCat;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
              hintText: 'ค้นหาสินค้า/หมวดหมู่…', border: InputBorder.none),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => Navigator.pushNamed(ctx, '/cart')),
        ],
      ),
      body: Column(
        children: [
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
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _colsForWidth(MediaQuery.of(ctx).size.width),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: .66,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => _CardItem(p: items[i], cs: cs),
            ),
          ),
        ],
      ),
    );
  }

  int _colsForWidth(double w) => w >= 900
      ? 4
      : w >= 600
          ? 3
          : 2;
}

class _CardItem extends StatelessWidget {
  const _CardItem({required this.p, required this.cs});
  final Product p;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(fit: StackFit.expand, children: [
                SimpleNetworkImageWidget(imageUrl: p.image, fit: BoxFit.cover),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('฿${_fmt(p.price)}',
                        style: TextStyle(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: InkWell(
                    onTap: () {
                      cartStore.add(
                          productId: p.id,
                          title: p.name,
                          price: p.price,
                          image: p.image,
                          qty: 1);
                      Navigator.pushNamed(context, '/cart');
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: cs.primary, shape: BoxShape.circle),
                        child: Icon(Icons.add_shopping_cart,
                            color: cs.onPrimary, size: 18)),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
              child: Text(p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(children: [
                Expanded(
                  child: Text(p.categoryName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                ),
                TextButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                ProductReviewsPage(productId: p.id))),
                    icon: const Icon(Icons.rate_review_outlined, size: 16),
                    label: const Text('รีวิว')),
              ]),
            ),
          ],
        ),
      );
}

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
