import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/state/reception.dart';
import 'package:coopaz_app/ui/common_widgets/loading_widget.dart';
import 'package:coopaz_app/ui/screens/reception/widget_product_autocomplete.dart';
import 'package:coopaz_app/ui/screens/reception/widget_supplier_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Reception extends StatefulWidget {
  const Reception({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Reception();
  }
}

class _Reception extends State<Reception> {
  @override
  Widget build(BuildContext context) {
    ReceptionModel receptionModel = context.watch<ReceptionModel>();
    AppModel appModel = context.watch<AppModel>();

    String actualPrice = '';
    String actualStock = '';
    if (receptionModel.selectedProduct != null) {
      actualPrice =
          '${receptionModel.selectedProduct?.price} €/${receptionModel.selectedProduct?.unit.unitAsString}';
      actualStock =
          '${receptionModel.selectedProduct?.stock} ${receptionModel.selectedProduct?.unit.unitAsString}';
    }

    return Row(children: [
      Expanded(
        flex: 3,
        child: Column(children: [
          Row(
            children: const [
              Expanded(child: Text("Fournisseur:")),
              Expanded(child: SupplierAutocomplete())
            ],
          ),
          Row(
            children: [
              const Expanded(child: ProductAutocomplete()),
              Expanded(child: Text(actualPrice)),
              Expanded(child: Text(actualStock)),
              Expanded(
                  child: TextFormField(
                controller: TextEditingController(
                    text:
                        receptionModel.modifiedPrice?.toStringAsFixed(2) ?? '')
                  ..selection = TextSelection.collapsed(
                      offset:
                          (receptionModel.modifiedPrice?.toStringAsFixed(2) ??
                                  '')
                              .length),
                decoration: const InputDecoration(
                  hintText: 'Prix modifié',
                ),
                validator: (String? value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return 'Prix invalide';
                  }
                  return null;
                },
                onChanged: (String value) {
                  receptionModel.modifiedPrice = double.tryParse(value);
                },
                style: TextStyle(
                  fontSize: appModel.mediumText * appModel.zoomText,
                ),
              )),
              Expanded(
                  child: TextFormField(
                controller: TextEditingController(
                    text:
                        receptionModel.modifiedStock?.toStringAsFixed(2) ?? '')
                  ..selection = TextSelection.collapsed(
                      offset:
                          (receptionModel.modifiedStock?.toStringAsFixed(2) ??
                                  '')
                              .length),
                decoration: const InputDecoration(
                  hintText: 'Stock modifié',
                ),
                validator: (String? value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return 'Stock invalide';
                  }
                  return null;
                },
                onChanged: (String value) {
                  receptionModel.modifiedStock = double.tryParse(value);
                },
                style: TextStyle(
                  fontSize: appModel.mediumText * appModel.zoomText,
                ),
              )),
              Expanded(
                  child: TextFormField(
                controller: TextEditingController(
                    text:
                        receptionModel.todayReception?.toStringAsFixed(2) ?? '')
                  ..selection = TextSelection.collapsed(
                      offset:
                          (receptionModel.todayReception?.toStringAsFixed(2) ??
                                  '')
                              .length),
                decoration: const InputDecoration(
                  hintText: 'Réception du jour',
                ),
                validator: (String? value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return 'Prix invalide';
                  }
                  return null;
                },
                onChanged: (String value) {
                  receptionModel.todayReception = double.tryParse(value);
                },
                style: TextStyle(
                  fontSize: appModel.mediumText * appModel.zoomText,
                ),
              )),
            ],
          ),
          if (receptionModel.isAwaitingSendFormResponse == false)
            Center(
                child: Container(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              child: FloatingActionButton.extended(
                  heroTag: null,
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  onPressed: () {
                    if (_validateAll()) {
                      log('Send form !!!');
                      _sendForm(receptionModel);
                    } else {
                      log('Form invalid');
                    }
                  },
                  tooltip: 'Valider le formulaire et envoyer la facture',
                  label: Text('Valider', textScaleFactor: appModel.zoomText)),
            ))
          else
            const Loading(text: "En attente du traitement de la facture...")
        ]),
      ),
      const VerticalDivider(),
      Expanded(
        flex: 1,
        child: Column(children: [
          Row(
            children: const [Expanded(child: Text("Bon de livraison"))],
          )
        ]),
      )
    ]);
  }

  bool _validateAll() {
    return true;
  }

  _sendForm(ReceptionModel model) async {
    model.isAwaitingSendFormResponse = true;

    // send data to macro
    Navigator.of(context).push(NotImplementedDialog<void>());
    // reset form

    model.isAwaitingSendFormResponse = false;
  }
}

class NotImplementedDialog<T> extends PopupRoute<T> {
  @override
  Color? get barrierColor => Colors.black.withAlpha(0x50);

  // This allows the popup to be dismissed by tapping the scrim or by pressing
  // the escape key on the keyboard.
  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismissible Dialog';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Center(
      // Provide DefaultTextStyle to ensure that the dialog's text style
      // matches the rest of the text in the app.
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        // UnconstrainedBox is used to make the dialog size itself
        // to fit to the size of the content.
        child: UnconstrainedBox(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              children: <Widget>[
                Text('Fonctionalité de réception pas encore prête...',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                const Text('Mais ça ne saurait tarder !!! ;-P'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
