import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/supplier.dart';
import 'package:flutter/foundation.dart';

class ReceptionModel extends ChangeNotifier {
  Product? _selectedProduct;
  double? _modifiedPrice;
  double? _modifiedStock;
  double? _todayReception;
  Supplier? _selectedSupplier;
  bool _isAwaitingSendFormResponse = false;

  Product? get selectedProduct => _selectedProduct;
  set selectedProduct(Product? p) {
    _selectedProduct = p;
    notifyListeners();
  }

  double? get modifiedPrice => _modifiedPrice;
  set modifiedPrice(double? p) {
    _modifiedPrice = p;
    notifyListeners();
  }

  double? get todayReception => _todayReception;
  set todayReception(double? p) {
    _todayReception = p;
    notifyListeners();
  }

  double? get modifiedStock => _modifiedStock;
  set modifiedStock(double? p) {
    _modifiedStock = p;
    notifyListeners();
  }

  Supplier? get selectedSupplier => _selectedSupplier;
  set selectedSupplier(Supplier? p) {
    _selectedSupplier = p;
    notifyListeners();
  }

  bool get isAwaitingSendFormResponse => _isAwaitingSendFormResponse;
  set isAwaitingSendFormResponse(b) {
    _isAwaitingSendFormResponse = b;
    notifyListeners();
  }

  void cleanForm() {
    _selectedProduct = null;
    _todayReception = null;
    _modifiedStock = null;
    _modifiedPrice = null;
    _selectedSupplier = null;
    notifyListeners();
  }
}
