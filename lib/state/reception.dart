import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/supplier.dart';
import 'package:flutter/foundation.dart';

class ReceptionModel extends ChangeNotifier {
  Product? _selectedProduct;
  Supplier? _selectedSupplier;
  bool _isAwaitingSendFormResponse = false;

  Product? get selectedProduct => _selectedProduct;
  set selectedProduct(Product? p) {
    _selectedProduct = p;
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
}
