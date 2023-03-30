import 'package:coopaz_app/actions/cash_register.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/state/cash_register.dart';
import 'package:coopaz_app/ui/screens/cash_register/widget_product_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:coopaz_app/logger.dart';
import 'package:provider/provider.dart';

class CartItemWidget extends StatelessWidget {
  CartItemWidget({
    super.key,
    required this.tab,
    required this.index,
  });

  final int tab;
  final int index;
  final NumberFormat numberFormat = NumberFormat('#,##0.00');

  @override
  Widget build(BuildContext context) {
    AppModel appModel = context.watch<AppModel>();
    double mediumText = 14 * appModel.zoomText;
    CashRegisterModel cashRegisterModel = context.watch<CashRegisterModel>();

    var cartItem = cashRegisterModel.cashRegisterTabs[tab]!.cart[index];

    var total = '';
    double? unitPrice = cartItem.product?.price;
    double? qty = double.tryParse(cartItem.qty ?? '');
    if (unitPrice != null && qty != null) {
      total = '${numberFormat.format(unitPrice * qty)} €';
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
                  tab: tab, index: index, cartItem: cartItem)),
          Expanded(
              flex: 1,
              child: !cashRegisterModel.isAwaitingSendFormResponse(tab)
                  ? Shortcuts(
                      shortcuts: <LogicalKeySet, Intent>{
                          LogicalKeySet(LogicalKeyboardKey.enter):
                              const AddNewCartItemIntent(),
                        },
                      child: TextFormField(
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
                              tab, index, cartItem);
                        },
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: mediumText,
                        ),
                      ))
                  : Text(
                      cashRegisterModel.cart(tab)[index].qty ?? '',
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
              child: !cashRegisterModel.isAwaitingSendFormResponse(tab)
                  ? IconButton(
                      focusNode: FocusNode(skipTraversal: true),
                      onPressed: () {
                        log('Delete line pressed');
                        cashRegisterModel.removeFromCart(tab, index);
                      },
                      icon: const Icon(Icons.delete),
                      tooltip: 'Supprimer ligne',
                    )
                  : Container()),
        ]));
  }
}
