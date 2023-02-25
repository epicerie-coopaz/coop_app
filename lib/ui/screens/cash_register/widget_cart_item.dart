//import 'dart:html';

import 'package:coopaz_app/actions/cash_register.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/cart_item.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/state/cash_register.dart';
import 'package:coopaz_app/ui/screens/cash_register/widget_product_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:coopaz_app/logger.dart';
import 'package:provider/provider.dart';

class CartItemWidget extends StatefulWidget {
  CartItemWidget({super.key, required this.index, required this.cartItem});

  final int index;
  final CartItem cartItem;
  final NumberFormat numberFormat = NumberFormat('#,##0.00');

  @override
  State<CartItemWidget> createState() {
    return _CartItemWidget();
  }
}

class _CartItemWidget extends State<CartItemWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppModel appModel = context.watch<AppModel>();
    double mediumText = 14 * appModel.zoomText;
    CashRegisterModel cashRegisterModel = context.watch<CashRegisterModel>();

    var total = '';
    double? unitPrice = widget.cartItem.product?.price;
    double? qty = double.tryParse(widget.cartItem.qty ?? '');
    if (unitPrice != null && qty != null) {
      total = '${widget.numberFormat.format(unitPrice * qty)} €';
    }

    String unitPriceAsString = '';
    if (widget.cartItem.product != null) {
      unitPriceAsString =
          '${widget.cartItem.product?.price}€/${widget.cartItem.product!.unit.unitAsString}';
    }

    return FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Row(children: <Widget>[
          Expanded(
              flex: 7,
              child: ProductAutocomplete(index: widget.index, cartItem: widget.cartItem)),
          Expanded(
              flex: 1,
              child: !cashRegisterModel.isAwaitingSendFormResponse
                  ? Shortcuts(
                      shortcuts: <LogicalKeySet, Intent>{
                          LogicalKeySet(LogicalKeyboardKey.enter):
                              const AddNewCartItemIntent(),
                        },
                      child: TextFormField(
                        controller: TextEditingController(
                            text: widget.cartItem.qty ?? '')
                          ..selection = TextSelection.collapsed(
                              offset: (widget.cartItem.qty ?? '').length),
                        decoration: const InputDecoration(
                          hintText: 'Quantité',
                        ),
                        validator: (String? value) {
                          if (value == null ||
                              value.isEmpty ||
                              double.tryParse(value) == null) {
                            return 'Quantité invalide';
                          }
                          return null;
                        },
                        onChanged: (String value) {
                          widget.cartItem.qty = value;
                          cashRegisterModel.modifyCartItem(
                              widget.index, widget.cartItem);
                        },
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: mediumText,
                        ),
                      ))
                  : Text(
                      cashRegisterModel.cart[widget.index].qty ?? '',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: mediumText,
                        ),
                    )),
          Expanded(
              flex: 1,
              child: Text(unitPriceAsString,
                  textAlign: TextAlign.right,
                  textScaleFactor: appModel.zoomText)),
          Expanded(
              flex: 1,
              child: Text(
                total,
                textScaleFactor: appModel.zoomText,
                textAlign: TextAlign.right,
              )),
          Expanded(
              flex: 1,
              child: !cashRegisterModel.isAwaitingSendFormResponse
                  ? IconButton(
                      focusNode: FocusNode(skipTraversal: true),
                      onPressed: () {
                        log('Delete line pressed');
                        cashRegisterModel.removeFromCart(widget.index);
                      },
                      icon: const Icon(Icons.delete),
                      tooltip: 'Supprimer ligne',
                    )
                  : Container()),
        ]));
  }
}
