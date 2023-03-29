//import 'dart:html';

import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/cart_item.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/state/cash_register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class ProductAutocomplete extends StatelessWidget {
  const ProductAutocomplete(
      {super.key,
      required this.tab,
      required this.index,
      required this.cartItem});

  final int tab;
  final int index;
  final CartItem cartItem;

  @override
  Widget build(BuildContext context) {
    AppModel appModel = context.watch<AppModel>();
    double mediumText = 14 * appModel.zoomText;
    CashRegisterModel cashRegisterModel = context.watch<CashRegisterModel>();

    return Autocomplete<Product>(
      initialValue: TextEditingValue(text: cartItem.product?.designation ?? ''),
      key: ValueKey(cartItem),
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
          style: TextStyle(fontSize: mediumText),
          enabled: !cashRegisterModel.isAwaitingSendFormResponse(tab),
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
                      AutocompleteHighlightedOption.of(context) == index;
                  if (highlight) {
                    SchedulerBinding.instance
                        .addPostFrameCallback((Duration timeStamp) {
                      Scrollable.ensureVisible(context, alignment: 0.5);
                    });
                  }
                  var styleBody = Theme.of(context).textTheme.bodyMedium;
                  return Container(
                    color: highlight ? Theme.of(context).focusColor : null,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 8,
                            child: Text(option.designation, style: styleBody)),
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
        cashRegisterModel.modifyCartItem(tab, index, CartItem(product: p));
      },
    );
  }
}
