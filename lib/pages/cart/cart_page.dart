// lib/pages/cart/cart_page.dart
import 'package:flutter/material.dart';
import '../../providers/cart_store.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cartStore,
      builder: (_, __) {
        final items = cartStore.items;
        return Scaffold(
          appBar: AppBar(
              centerTitle: true, title: Text('ตะกร้าสินค้า (${items.length})')),
          body: items.isEmpty
              ? const Center(child: Text('ตะกร้ายังว่างเปล่า'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return Card(
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _img(it.image),
                        ),
                        title: Text(it.title,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text('฿${it.price.toStringAsFixed(0)}',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w800)),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, 
                            children: [
                          IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () => cartStore.dec(it)),
                          Text('${it.qty}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () => cartStore.inc(it)),
                          IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: () => cartStore.remove(it)),
                        ]),
                      ),
                    );
                  },
                ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(children: [
                const Text('ยอดชำระ'),
                const Spacer(),
                Text('฿${cartStore.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: items.isEmpty
                      ? null
                      : () => Navigator.pushNamed(context, '/checkout'),
                  child: const Text('ชำระเงิน'),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _img(String path) => path.startsWith('http')
      ? Image.network(path, width: 64, height: 64, fit: BoxFit.cover)
      : Image.asset(path, width: 64, height: 64, fit: BoxFit.cover);
}
