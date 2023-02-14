import 'package:coopaz_app/podo/cart_item.dart';
import 'package:coopaz_app/state/cash_register.dart';
import 'package:flutter/material.dart';

class AddNewCartItemIntent extends Intent {
  const AddNewCartItemIntent();
}

class AddNewCartItemAction extends Action<AddNewCartItemIntent> {
  AddNewCartItemAction(this.model);

  final CashRegisterModel model;

  @override
  Object? invoke(covariant AddNewCartItemIntent intent) {
    model.addToCart(CartItem());

    return null;
  }
}
