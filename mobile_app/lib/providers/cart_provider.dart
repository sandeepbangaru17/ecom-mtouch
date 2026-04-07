import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.total);

  void addToCart(Product product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void increment(int productId) {
    final item = _items.firstWhere((entry) => entry.product.id == productId);
    item.quantity += 1;
    notifyListeners();
  }

  void decrement(int productId) {
    final index = _items.indexWhere((entry) => entry.product.id == productId);
    if (index < 0) {
      return;
    }
    if (_items[index].quantity == 1) {
      _items.removeAt(index);
    } else {
      _items[index].quantity -= 1;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
