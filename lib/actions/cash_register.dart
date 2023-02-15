import 'package:coopaz_app/podo/cart_item.dart';
import 'package:coopaz_app/state/cash_register.dart';
import 'package:coopaz_app/ui/screens/cash_register/cart_list_panel.dart';
import 'package:flutter/material.dart';

class AddNewCartItemIntent extends Intent {
  const AddNewCartItemIntent();
}

class AddNewCartItemAction extends Action<AddNewCartItemIntent> {
  AddNewCartItemAction(this.model, this.cartList);

  final CashRegisterModel model;
  final CartList cartList;

  @override
  Object? invoke(covariant AddNewCartItemIntent intent) {
    cartList.validateAll();
    model.addToCart(CartItem());

    return null;
  }
}
