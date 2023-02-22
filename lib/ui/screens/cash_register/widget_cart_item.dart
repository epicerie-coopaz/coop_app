//import 'dart:html';

import 'package:coopaz_app/actions/cash_register.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/cart_item.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/state/cash_register.dart';
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
              child: Autocomplete<Product>(
                initialValue: TextEditingValue(
                    text: widget.cartItem.product?.designation ?? ''),
                key: ValueKey(widget.cartItem),
                displayStringForOption: (Product p) => p.designation,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<Product>.empty();
                  }
                  return appModel.products.where((Product p) {
                    return p.stock > 0.0;
                  }).where((Product p) {
                    List<String> matchList =
                        textEditingValue.text.toLowerCase().split(' ');
                    bool matchAll = true;
                    for (String match in matchList) {
                      if (!p.toString().toLowerCase().contains(match)) {
                        matchAll = false;
                        break;
                      }
                    }

                    return matchAll;
                  });
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Produit',
                    ),
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    style: TextStyle(fontSize: 14 * appModel.zoomText),
                    enabled: !cashRegisterModel.isAwaitingSendFormResponse,
                    validator: (String? value) {
                      String? result;
                      if (value?.isEmpty ?? false) {
                        result = 'Produit invalide';
                      }
                      return result;
                    },
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Material(
                    elevation: 4.0,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Product option = options.elementAt(index);
                        return InkWell(
                          onTap: () {
                            onSelected(option);
                          },
                          child: Builder(builder: (BuildContext context) {
                            final bool highlight =
                                AutocompleteHighlightedOption.of(context) ==
                                    index;
                            if (highlight) {
                              SchedulerBinding.instance
                                  .addPostFrameCallback((Duration timeStamp) {
                                Scrollable.ensureVisible(context,
                                    alignment: 0.5);
                              });
                            }
                            var styleBody =
                                Theme.of(context).textTheme.bodyMedium;
                            return Container(
                              color: highlight
                                  ? Theme.of(context).focusColor
                                  : null,
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 8,
                                      child: Text(option.designation,
                                          style: styleBody)),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                          '${option.price}€/${option.unit.unitAsString}',
                                          style: styleBody)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(option.stock.toString(),
                                          style: styleBody)),
                                ],
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  );
                },
                onSelected: (p) {
                  cashRegisterModel.modifyCartItem(
                      widget.index, CartItem(product: p));
                },
              )),
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
                          fontSize: 14 * appModel.zoomText,
                        ),
                      ))
                  : Text(
                      cashRegisterModel.cart[widget.index].qty ?? '',
                      textAlign: TextAlign.right,
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
