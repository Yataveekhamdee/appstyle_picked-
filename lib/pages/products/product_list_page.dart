import 'package:flutter/material.dart'; 
import 'package:provider/provider.dart'; 

import '../../providers/product_provider.dart';   
import '../../providers/category_provider.dart'; 
import '../../providers/cart_store.dart';       
import '../../models/product_model.dart';        
import '../../widgets/simple_network_image_widget.dart'; // แสดงรูปจาก URL
import 'product_reviews_page.dart';             

class ProductListPage extends StatefulWidget { 
  const ProductListPage({super.key});
  @override
  State<ProductListPage> createState() => _ProductListState();
}

class _ProductListState extends State<ProductListPage> {
  final _search = TextEditingController(); // ช่องค้นหาสินค้า
  String? _catId; // id หมวดหมู่ที่เลือก (null = ทั้งหมด)

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลหลังจากหน้าจอถูกสร้างครั้งแรก
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();   
      context.read<CategoryProvider>().loadCategories(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProductProvider>(); 
    final cp = context.watch<CategoryProvider>(); 

    final kw = _search.text.trim().toLowerCase(); 
    final items = pp.products.where((p) { // กรองสินค้า
      final hitKw = kw.isEmpty || p.name.toLowerCase().contains(kw); 
      final hitCat = _catId == null || p.categoryId == _catId; 
      return hitKw && hitCat; // ต้องผ่านทั้ง 2 เงื่อนไข
    }).toList();

    return Scaffold( 
      appBar: AppBar(
        title: TextField( // ช่องค้นหาอยู่บน AppBar
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
          SizedBox(
            height: 52, 
            child: ListView( 
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                ChoiceChip( // ปุ่ม “ทั้งหมด”
                  label: const Text('ทั้งหมด'),
                  selected: _catId == null, // ถ้ายังไม่เลือกหมวด
                  onSelected: (_) => setState(() => _catId = null), // รีเซ็ตหมวด
                ),
                for (final c in cp.activeCategories) ...[ // สร้างปุ่มหมวดจาก provider
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(c.name), // ชื่อหมวด
                    selected: _catId == c.id, // กำลังเลือกหมวดนี้ไหม
                    onSelected: (_) => setState(() => _catId = c.id), // เปลี่ยนหมวด
                  ),
                ],
              ],
            ),
          ),

          Expanded( // ส่วนที่เหลือของหน้าจอ
            child: LayoutBuilder(
              builder: (_, cons) {
                final w = cons.maxWidth; // ความกว้างหน้าจอ
                final cols = w >= 900 ? 4 : (w >= 600 ? 3 : 2); // จอใหญ่แสดงหลายคอลัมน์
                return GridView.builder( 
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols, 
                    crossAxisSpacing: 12, 
                    mainAxisSpacing: 12, 
                    childAspectRatio: .66, 
                  ),
                  itemCount: items.length, 
                  itemBuilder: (_, i) => _ProductCard(p: items[i]), // แสดงสินค้าแต่ละอัน
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//  การ์ดสินค้า 
class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.p});
  final Product p; // สินค้าตัวนี้

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; 

    return Card( 
      clipBehavior: Clip.antiAlias, // ตัดมุมให้โค้งตามการ์ด
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio( // ส่วนรูปสินค้า
            aspectRatio: 1, 
            child: Stack( // วางหลาย widget ซ้อนกัน
              fit: StackFit.expand,
              children: [
                SimpleNetworkImageWidget(imageUrl: p.image, fit: BoxFit.cover), // รูปสินค้า

                Positioned( // ป้ายราคา
                  left: 10, bottom: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer, // สีพื้นป้าย
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Text('฿${_fmt(p.price)}', // แสดงราคา
                          style: TextStyle(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.w800,
                          )),
                    ),
                  ),
                ),

                Positioned( // ปุ่มตะกร้า
                  right: 10, bottom: 10,
                  child: InkWell( // คลิกได้
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      cartStore.add( // เพิ่มสินค้าเข้า cart
                        productId: p.id,
                        title: p.name,
                        price: p.price,
                        image: p.image,
                        qty: 1,
                      );
                      Navigator.pushNamed(context, '/cart'); // ไปหน้าตะกร้า
                    },
                    child: Container( // วงกลมปุ่ม
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                      child: Icon(Icons.add_shopping_cart, color: cs.onPrimary, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding( // ชื่อสินค้า
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
            child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),

          Padding( // หมวดสินค้า + ปุ่มรีวิว
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    p.categoryName ?? '', // หมวดสินค้า
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ),
                TextButton.icon( // ปุ่มรีวิว
                  icon: const Icon(Icons.rate_review_outlined, size: 16),
                  label: const Text('รีวิว'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductReviewsPage(productId: p.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ฟังก์ชันช่วยฟอร์แมตราคา 
String _fmt(double v) =>
    v == v.roundToDouble() // ถ้าเป็นเลขเต็ม
        ? v.toStringAsFixed(0) // แสดงแบบไม่มี .00
        : v.toStringAsFixed(2); // ถ้ามีทศนิยม แสดง 2 ตำแหน่ง
