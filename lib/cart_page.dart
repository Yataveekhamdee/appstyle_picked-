import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('ตะกร้าสินค้า')),
      body: cart.lines.isEmpty
          ? const Center(child: Text('ยังไม่มีสินค้าในตะกร้า'))
          : ListView.builder(
              itemCount: cart.lines.length,
              itemBuilder: (_, i) {
                final line = cart.lines[i];
                return ListTile(
                  leading: Image.asset(line.product.image, width: 60),
                  title: Text(line.product.title),
                  subtitle: Text("฿${line.product.price} x ${line.qty}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.remove), onPressed: () => cart.dec(line)),
                      Text('${line.qty}'),
                      IconButton(icon: const Icon(Icons.add), onPressed: () => cart.inc(line)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => cart.remove(line)),
                    ],
                  ),
                  onTap: () => cart.toggle(line),
                  leadingAndTrailingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        child: FilledButton(
          onPressed: cart.total == 0 ? null : () => Navigator.pushNamed(context, '/checkout'),
          child: Text("ชำระเงิน ฿${cart.total.toStringAsFixed(0)}"),
        ),
      ),
    );
  }
}
