import 'package:coopaz_app/actions/cash_register.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/state/cash_register.dart';
import 'package:coopaz_app/ui/screens/cash_register/widget_product_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:coopaz_app/logger.dart';
import 'package:provider/provider.dart';

class CartItemWidget extends StatefulWidget {
  CartItemWidget({
    super.key,
    required this.tab,
    required this.index,
  });

  final int tab;
  final int index;
  final NumberFormat numberFormat = NumberFormat('#,##0.00');

  @override
  State<CartItemWidget> createState() => _CartItemWidget();
}

class _CartItemWidget extends State<CartItemWidget> {
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppModel appModel = context.watch<AppModel>();
    double mediumText = 14 * appModel.zoomText;
    CashRegisterModel cashRegisterModel = context.watch<CashRegisterModel>();

    var cartItem =
        cashRegisterModel.cashRegisterTabs[widget.tab]!.cart[widget.index];

    var total = '';
    double? unitPrice = cartItem.product?.price;
    double? qty = double.tryParse(cartItem.qty ?? '');
    if (unitPrice != null && qty != null) {
      total = '${widget.numberFormat.format(unitPrice * qty)} €';
    }

    String unitPriceAsString = '';
    if (cartItem.product != null) {
      unitPriceAsString =
          '${cartItem.product?.price}€/${cartItem.product!.unit.unitAsString}';
    }

    return FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Row(children: <Widget>[
          Expanded(
              flex: 7,
              child: ProductAutocomplete(
                  tab: widget.tab, index: widget.index, cartItem: cartItem)),
          Expanded(
              flex: 1,
              child: !cashRegisterModel.isAwaitingSendFormResponse(widget.tab)
                  ? Shortcuts(
                      shortcuts: <LogicalKeySet, Intent>{
                          LogicalKeySet(LogicalKeyboardKey.enter):
                              const AddNewCartItemIntent(),
                        },
                      child: TextFormField(
                        focusNode: myFocusNode,
                        controller:
                            TextEditingController(text: cartItem.qty ?? '')
                              ..selection = TextSelection.collapsed(
                                  offset: (cartItem.qty ?? '').length),
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
                          cartItem.qty = value;
                          cashRegisterModel.modifyCartItem(
                              widget.tab, widget.index, cartItem);
                        },
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: mediumText,
                        ),
                      ))
                  : Text(
                      cashRegisterModel.cart(widget.tab)[widget.index].qty ??
                          '',
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
              child: !cashRegisterModel.isAwaitingSendFormResponse(widget.tab)
                  ? IconButton(
                      focusNode: FocusNode(skipTraversal: true),
                      onPressed: () {
                        log('Delete line pressed');
                        cashRegisterModel.removeFromCart(
                            widget.tab, widget.index);
                      },
                      icon: const Icon(Icons.delete),
                      tooltip: 'Supprimer ligne',
                    )
                  : Container()),
        ]));
  }
}
