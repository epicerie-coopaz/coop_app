//import 'dart:html';

import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/cart_item.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/state/cash_register.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:coopaz_app/logger.dart';
import 'package:provider/provider.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key, required this.formKey});

  final GlobalKey<FormState> formKey;
  static NumberFormat numberFormat = NumberFormat('#,##0.00');

  @override
  Widget build(BuildContext context) {
    log('build productList');

    var styleHeaders = Theme.of(context)
        .primaryTextTheme
        .titleMedium
        ?.apply(color: Theme.of(context).colorScheme.primary);

    AppModel appModel = context.watch<AppModel>();
    CashRegisterModel cashRegisterModel = context.watch<CashRegisterModel>();

    List<Row> productLineWidgets =
        _createProductLineWidgets(appModel, cashRegisterModel);

    return Column(
      children: [
        Row(children: <Widget>[
          Expanded(
              flex: 8,
              child: Text(
                'Produit',
                style: styleHeaders,
              )),
          Expanded(
              flex: 1,
              child: Text(
                'Qté',
                style: styleHeaders,
                textAlign: TextAlign.right,
              )),
          Expanded(
              flex: 1,
              child: Text(
                'Prix unit.',
                style: styleHeaders,
                textAlign: TextAlign.right,
              )),
          Expanded(
              flex: 1,
              child: Text(
                'Unité',
                style: styleHeaders,
                textAlign: TextAlign.right,
              )),
          Expanded(
              flex: 1,
              child: Text(
                'Total',
                style: styleHeaders,
                textAlign: TextAlign.right,
              )),
          const SizedBox(width: 71),
        ]),
        Column(children: productLineWidgets),
        const SizedBox(height: 40),
        Row(children: [
          Expanded(
              flex: 10,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  log('+ pressed');
                  _validateAll();
                  cashRegisterModel.addToCart(CartItem());
                },
                child: const Icon(Icons.add),
              )),
          const Expanded(flex: 7, child: SizedBox())
        ]),
      ],
    );
  }

  bool _validateAll() {
    log(formKey.currentState.toString());
    bool valid = false;
    if (formKey.currentState != null) {
      valid = formKey.currentState!.validate();
    }
    return valid;
  }

  List<Row> _createProductLineWidgets(
      AppModel appModel, CashRegisterModel cashRegisterModel) {
    List<Row> products = [];
    for (var entry in cashRegisterModel.cart.asMap().entries) {
      var product = _createProductLineWidget(
          appModel, cashRegisterModel, entry.key, entry.value);
      products.add(product);
    }
    return products;
  }

  Row _createProductLineWidget(AppModel appModel,
      CashRegisterModel cashRegisterModel, int index, CartItem cartItem) {
    var total = '';
    double? unitPrice = double.tryParse(cartItem.unitPrice ?? '');
    double? qty = double.tryParse(cartItem.qty ?? '');
    if (unitPrice != null && qty != null) {
      total = '${numberFormat.format(unitPrice * qty)} €';
    }

    var productWidget = Row(children: <Widget>[
      Expanded(
          flex: 8,
          child: Autocomplete<Product>(
            initialValue: TextEditingValue(text: cartItem.name ?? ''),
            key: ValueKey(cartItem),
            displayStringForOption: (Product p) => p.designation,
            optionsBuilder: (TextEditingValue textEditingValue) async {
              if (textEditingValue.text == '') {
                return const Iterable<Product>.empty();
              }
              return appModel.products.where((Product p) {
                return p
                    .toString()
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (p) {
              cashRegisterModel.modifyCartItem(
                  index,
                  CartItem(
                      name: p.designation,
                      unit: p.unit.unitAsString,
                      unitPrice: p.price.toStringAsFixed(2)));
            },
          )),
      Expanded(
          flex: 1,
          child: TextFormField(
            controller: TextEditingController(text: cartItem.qty ?? '')
              ..selection =
                  TextSelection.collapsed(offset: (cartItem.qty ?? '').length),
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
              cashRegisterModel.modifyCartItem(index, cartItem);
            },
            textAlign: TextAlign.right,
          )),
      Expanded(
          flex: 1,
          child: Text(
            cartItem.unitPrice ?? '',
            textAlign: TextAlign.right,
          )),
      Expanded(
          flex: 1,
          child: Text(
            cartItem.unit ?? '',
            textAlign: TextAlign.right,
          )),
      Expanded(
          flex: 1,
          child: Text(
            total,
            textAlign: TextAlign.right,
          )),
      const SizedBox(width: 15),
      IconButton(
        onPressed: () {
          log('Delete line pressed');
          cashRegisterModel.removeFromCart(index);
          _validateAll();
        },
        icon: const Icon(Icons.delete),
        tooltip: 'Supprimer ligne',
      )
    ]);

    return productWidget;
  }
}
