import 'dart:collection';

import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/cart_item.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/podo/payment_method.dart';
import 'package:flutter/foundation.dart';

class CashRegisterModel extends ChangeNotifier {
  final Map<int, CashRegister> _cashRegiserTabs = {1: CashRegister()};

  deleteTab(int index) {
    _cashRegiserTabs.remove(index);
    notifyListeners();
  }

  addTab() {
    int tabNumber = 1;
    if (_cashRegiserTabs.isNotEmpty) {
      tabNumber = _cashRegiserTabs.keys.last + 1;
    }
    _cashRegiserTabs[tabNumber] = CashRegister();
    notifyListeners();
  }

  UnmodifiableMapView<int, CashRegister> get cashRegisterTabs {
    return UnmodifiableMapView(_cashRegiserTabs);
  }

  bool isAwaitingSendFormResponse(int tab) =>
      _cashRegiserTabs[tab]!.isAwaitingSendFormResponse;
  setIsAwaitingSendFormResponse(int tab, bool b) {
    _cashRegiserTabs[tab]?.isAwaitingSendFormResponse = b;
    notifyListeners();
  }

  String chequeOrTransferNumber(int tab) =>
      _cashRegiserTabs[tab]!.chequeOrTransferNumber;
  setChequeOrTransferNumber(int tab, s) {
    _cashRegiserTabs[tab]!.chequeOrTransferNumber = s;
    notifyListeners();
  }

  PaymentMethod selectedPaymentMethod(int tab) =>
      _cashRegiserTabs[tab]!.selectedPaymentMethod;
  setSelectedPaymentMethod(int tab, pm) {
    _cashRegiserTabs[tab]!.selectedPaymentMethod = pm;
    notifyListeners();
  }

  Member? selectedMember(int tab) => _cashRegiserTabs[tab]!.selectedMember;
  setSelectedMember(int tab, m) {
    _cashRegiserTabs[tab]!.selectedMember = m;
    notifyListeners();
  }

  UnmodifiableListView<CartItem> cart(int tab) {
    return UnmodifiableListView(_cashRegiserTabs[tab]!.cart);
  }

  void addToCart(int tab, CartItem item) {
    _cashRegiserTabs[tab]!.addToCart(item);
    notifyListeners();
  }

  void modifyCartItem(int tab, int i, CartItem cartItem) {
    _cashRegiserTabs[tab]!.modifyCartItem(i, cartItem);
    notifyListeners();
  }

  void removeFromCart(int tab, int i) {
    _cashRegiserTabs[tab]!.removeFromCart(i);
    notifyListeners();
  }

  void cleanCart(int tab) {
    _cashRegiserTabs[tab]!.cleanCart();
    notifyListeners();
  }
}

class CashRegister {
  CashRegister() {
    log("New CashRegister");
  }

  final List<CartItem> _cart = [CartItem()];
  Member? _selectedMember;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.card;
  String _chequeOrTransferNumber = '';
  bool _isAwaitingSendFormResponse = false;

  bool get isAwaitingSendFormResponse => _isAwaitingSendFormResponse;
  set isAwaitingSendFormResponse(b) {
    _isAwaitingSendFormResponse = b;
  }

  String get chequeOrTransferNumber => _chequeOrTransferNumber;
  set chequeOrTransferNumber(s) {
    _chequeOrTransferNumber = s;
  }

  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  set selectedPaymentMethod(pm) {
    _selectedPaymentMethod = pm;
  }

  Member? get selectedMember => _selectedMember;
  set selectedMember(m) {
    _selectedMember = m;
  }

  UnmodifiableListView<CartItem> get cart {
    return UnmodifiableListView(_cart);
  }

  void addToCart(CartItem item) {
    _cart.add(item);
  }

  void modifyCartItem(int i, CartItem cartItem) {
    _cart[i] = cartItem;
  }

  void removeFromCart(int i) {
    _cart.removeAt(i);
  }

  void cleanCart() {
    _cart.clear();
    _cart.add(CartItem());
    _selectedPaymentMethod = PaymentMethod.card;
    _selectedMember = null;
    _chequeOrTransferNumber = '';
  }
}
