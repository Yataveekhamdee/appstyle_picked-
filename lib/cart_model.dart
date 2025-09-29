import 'package:flutter/material.dart';
import 'main.dart'; // เพื่อใช้ ProductItem

class CartLine {
  final ProductItem product;
  int qty;
  bool selected;
  CartLine({required this.product, this.qty = 1, this.selected = true});
}

class CartModel extends ChangeNotifier {
  final List<CartLine> _lines = [];
  List<CartLine> get lines => _lines;

  void add(ProductItem p, {int qty = 1}) {
    final idx = _lines.indexWhere((e) => e.product.title == p.title);
    if (idx >= 0) {
      _lines[idx].qty += qty;
    } else {
      _lines.add(CartLine(product: p, qty: qty));
    }
    notifyListeners();
  }

  void remove(CartLine line) {
    _lines.remove(line);
    notifyListeners();
  }

  void toggle(CartLine line) {
    line.selected = !line.selected;
    notifyListeners();
  }

  void inc(CartLine line) {
    line.qty++;
    notifyListeners();
  }

  void dec(CartLine line) {
    if (line.qty > 1) {
      line.qty--;
    } else {
      _lines.remove(line);
    }
    notifyListeners();
  }

  double get total =>
      _lines.where((e) => e.selected).fold(0, (sum, e) => sum + e.product.price * e.qty);
}
