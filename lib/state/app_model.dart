import 'dart:collection';

import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/supplier.dart';
import 'package:flutter/foundation.dart';

class AppModel extends ChangeNotifier {
  final List<Member> _members = [];
  final List<Product> _products = [];
  final List<Supplier> _suppliers = [];

  // Text Size section

  double _textSizeFactor = 1.0;
  double zoomStep = 0.2;

  double get zoomText => _textSizeFactor;
  set zoomText(double textSizeFactor) {
    _textSizeFactor = textSizeFactor;
    notifyListeners();
  }

  double smallText = 11;
  double mediumText = 14;
  double bigText = 20;

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

  // Suppliers section

  UnmodifiableListView<Supplier> get suppliers => UnmodifiableListView(_suppliers);
  set suppliers(List<Supplier> suppliers) {
    if (!listEquals(_suppliers, suppliers)) {
      _suppliers.clear();
      _suppliers.addAll(suppliers);
      notifyListeners();
    }
  }
}
