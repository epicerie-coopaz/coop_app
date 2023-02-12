import 'dart:collection';

import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:flutter/foundation.dart';

class AppModel extends ChangeNotifier {
  final List<Member> _members = [];
  final List<Product> _products = [];
  double _textSize = 1.0;
  int Function(Member, Member) _memberCompare = (a,b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());

  // Text Size section
  double get zoomText => _textSize;
  set zoomText(double textSize) {
    _textSize = textSize;
    notifyListeners();
  }

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

  setMemberSort(int Function(Member, Member) compare) {
    _memberCompare = compare;
    notifyListeners();
  }

  UnmodifiableListView<Member> memberSorted() {
    _members.sort(_memberCompare);
    return UnmodifiableListView(_members);
  }
}
