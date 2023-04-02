//import 'dart:html';

import 'package:coopaz_app/actions/cash_register.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/state/cash_register.dart';
import 'package:coopaz_app/ui/screens/cash_register/widget_cart_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:coopaz_app/logger.dart';
import 'package:provider/provider.dart';

class CartList extends StatelessWidget {
  CartList({super.key, required this.formKey, required this.tab});

  final int tab;
  final GlobalKey<FormState> formKey;
  final NumberFormat numberFormat = NumberFormat('#,##0.00');

  final ScrollController scrollController = ScrollController();

  bool validateAll() {
    log(formKey.currentState.toString());
    bool valid = false;
    if (formKey.currentState != null) {
      formKey.currentState!.save();
      valid = formKey.currentState!.validate();
    }
    return valid;
  }

  @override
  Widget build(BuildContext context) {
    log('build $runtimeType');

    var styleHeaders = Theme.of(context)
        .primaryTextTheme
        .titleMedium
        ?.apply(color: Theme.of(context).colorScheme.primary);

    AppModel appModel = context.watch<AppModel>();
    double bigText = appModel.bigText * appModel.zoomText;
    CashRegisterModel cashRegisterModel = context.watch<CashRegisterModel>();

    List<CartItemWidget> productLineWidgets =
        _createProductLineWidgets(appModel, cashRegisterModel);

    return Actions(
        dispatcher: const ActionDispatcher(),
        actions: <Type, Action<Intent>>{
          AddNewCartItemIntent:
              AddNewCartItemAction(tab, cashRegisterModel, this),
        },
        child: Builder(builder: (context) {
          return Column(
            children: [
              Row(children: <Widget>[
                Expanded(
                    flex: 7,
                    child: Text(
                      'Produit',
                      textScaleFactor: appModel.zoomText,
                      style: styleHeaders,
                    )),
                Expanded(
                    flex: 1,
                    child: Text(
                      'Qté',
                      textScaleFactor: appModel.zoomText,
                      style: styleHeaders,
                      textAlign: TextAlign.right,
                    )),
                Expanded(
                    flex: 1,
                    child: Text(
                      'Prix U.',
                      textScaleFactor: appModel.zoomText,
                      style: styleHeaders,
                      textAlign: TextAlign.right,
                    )),
                Expanded(
                    flex: 1,
                    child: Text(
                      'Prix',
                      textScaleFactor: appModel.zoomText,
                      style: styleHeaders,
                      textAlign: TextAlign.right,
                    )),
                Expanded(flex: 1, child: Container()),
              ]),
              Expanded(
                  child: FocusTraversalGroup(
                      child: ListView.builder(
                itemCount: productLineWidgets.length,
                controller: scrollController,
                itemBuilder: (context, index) {
                  return productLineWidgets[index];
                },
              ))),
              const SizedBox(height: 40),
              Row(children: [
                !cashRegisterModel.isAwaitingSendFormResponse(tab)
                    ? FloatingActionButton.extended(
                        heroTag: null,
                        focusNode: FocusNode(skipTraversal: true),
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          log('+ pressed');
                          Actions.maybeInvoke<AddNewCartItemIntent>(
                              context, const AddNewCartItemIntent());

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (scrollController.hasClients) {
                              scrollController.animateTo(
                                  scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut);
                            }
                          });
                        },
                        label: Icon(Icons.add, size: bigText),
                        tooltip: 'Ajouter une ligne produit',
                      )
                    : Container()
              ]),
            ],
          );
        }));
  }

  List<CartItemWidget> _createProductLineWidgets(
      AppModel appModel, CashRegisterModel cashRegisterModel) {
    List<CartItemWidget> products = [];
    for (var entry in cashRegisterModel.cart(tab).asMap().entries) {
      var product = CartItemWidget(
        tab: tab,
        index: entry.key,
      );
      products.add(product);
    }
    return products;
  }
}
