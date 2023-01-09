import 'dart:collection';

import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/cart_item.dart';
import 'package:flutter/foundation.dart';

class AppModel extends ChangeNotifier {
  final List<CartItem> _cart = [];
  final List<Member> _members = [];
  final List<Product> _products = [];

  // Products section

  UnmodifiableListView<Product> get products => UnmodifiableListView(_products);
  set products(List<Product> products) {
    if (!listEquals(_products, products)) {
      _products.clear();
      _products.addAll(products);
      notifyListeners();
    }
  }

  // Members section

  UnmodifiableListView<Member> get members => UnmodifiableListView(_members);
  set members(List<Member> members) {
    if (!listEquals(_members, members)) {
      _members.clear();
      _members.addAll(members);
      notifyListeners();
    }
  }

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
