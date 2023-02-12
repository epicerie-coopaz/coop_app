import 'dart:collection';

import 'package:coopaz_app/podo/cart_item.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/podo/payment_method.dart';
import 'package:flutter/foundation.dart';

class CashRegisterModel extends ChangeNotifier {
  final List<CartItem> _cart = [CartItem()];
  Member? _selectedMember;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.card;
  String _chequeOrTransferNumber = '';
  bool _isAwaitingSendFormResponse = false;

  bool get isAwaitingSendFormResponse => _isAwaitingSendFormResponse;
  set isAwaitingSendFormResponse(b) {
    _isAwaitingSendFormResponse = b;
    notifyListeners();
  }

  String get chequeOrTransferNumber => _chequeOrTransferNumber;
  set chequeOrTransferNumber(s) {
    _chequeOrTransferNumber = s;
    notifyListeners();
  }

  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  set selectedPaymentMethod(pm) {
    _selectedPaymentMethod = pm;
    notifyListeners();
  }

  Member? get selectedMember => _selectedMember;
  set selectedMember(m) {
    _selectedMember = m;
    notifyListeners();
  }

  UnmodifiableListView<CartItem> get cart {
    return UnmodifiableListView(_cart);
  }

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
    _cart.add(CartItem());
    _selectedPaymentMethod = PaymentMethod.card;
    _selectedMember = null;
    _chequeOrTransferNumber = '';
    notifyListeners();
  }
}
