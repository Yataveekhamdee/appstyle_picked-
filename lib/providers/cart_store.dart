// cart_store.dart
import 'package:flutter/foundation.dart';

class CartItem {
  final String title;
  final double price;
  final String image;
  int qty;
  CartItem({
    required this.title,
    required this.price,
    required this.image,
    this.qty = 1,
  });
}

class CartStore extends ChangeNotifier {
  final List<CartItem> items = [];

  double get total =>
      items.fold(0.0, (sum, it) => sum + it.price * it.qty);

  void add({
    required String title,
    required double price,
    required String image,
    int qty = 1,
  }) {
    final idx = items.indexWhere(
      (e) => e.title == title && e.image == image && e.price == price,
    );
    if (idx >= 0) {
      items[idx].qty += qty;
    } else {
      items.add(CartItem(title: title, price: price, image: image, qty: qty));
    }
    notifyListeners();
  }

  void inc(CartItem it) { it.qty++; notifyListeners(); }
  void dec(CartItem it) { it.qty > 1 ? it.qty-- : items.remove(it); notifyListeners(); }
  void remove(CartItem it) { items.remove(it); notifyListeners(); }
  void clear() { items.clear(); notifyListeners(); }
}

final cartStore = CartStore();