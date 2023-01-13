import 'dart:collection';

import 'package:coopaz_app/podo/cart_item.dart';
import 'package:flutter/foundation.dart';

class CashRegisterModel extends ChangeNotifier {
  final List<CartItem> _cart = [];

  // Cart section

  UnmodifiableListView<CartItem> get cart => UnmodifiableListView(_cart);

  void addToCart(CartItem item) {
    _cart.add(item);
    notifyListeners();
  }

  void modifyCartItem(int i, CartItem cartItem) {
    _cart[i] = cartItem;
    notifyListeners();
  }

  void removeFromCart(int i) {
    _cart.removeAt(i);
    notifyListeners();
  }

  void cleanCart() {
    _cart.clear();
    notifyListeners();
  }
}
