import 'package:coopaz_app/podo/cart_item.dart';
import 'package:coopaz_app/state/cash_register.dart';
import 'package:coopaz_app/ui/screens/cash_register/panel_cart_list.dart';
import 'package:flutter/material.dart';

class AddNewCartItemIntent extends Intent {
  const AddNewCartItemIntent();
}

class AddNewCartItemAction extends Action<AddNewCartItemIntent> {
  AddNewCartItemAction(this.tab, this.model, this.cartList);

  final int tab;
  final CashRegisterModel model;
  final CartList cartList;

  @override
  Object? invoke(covariant AddNewCartItemIntent intent) {
    cartList.validateAll();
    model.addToCart(tab, CartItem());

    return null;
  }
}
