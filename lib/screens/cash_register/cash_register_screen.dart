import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:coopaz_app/logger.dart';

class CashRegisterScreen extends StatefulWidget {
  const CashRegisterScreen({super.key});

  @override
  State<CashRegisterScreen> createState() => _CashRegisterScreenState();
}

class _CashRegisterScreenState extends State<CashRegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String title = 'Caisse';
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  static const List<String> list = <String>['CB', 'Cheque', 'Virement'];
  NumberFormat numberFormat = NumberFormat("#,##0.00");

  //Form data
  String dropdownValue = list.first;
  DateTime date = DateTime.now();

  double quantity = 0.0;
  double unitPrice = 0.0;

  @override
  Widget build(BuildContext context) {
    log('build screen $title');

    var styleHeaders = Theme.of(context)
        .primaryTextTheme
        .titleLarge
        ?.apply(color: Colors.blue);

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Form(
          key: _formKey,
          child: Row(children: [
            Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Row(children: <Widget>[
                      Expanded(
                          flex: 4,
                          child: Text(
                            "Produit",
                            style: styleHeaders,
                          )),
                      Expanded(
                          flex: 1,
                          child: Text(
                            "Quantité",
                            style: styleHeaders,
                          )),
                      Expanded(
                          flex: 1,
                          child: Text(
                            "Prix unitaire",
                            style: styleHeaders,
                          )),
                      Expanded(
                          flex: 1,
                          child: Text(
                            "Total",
                            style: styleHeaders,
                          )),
                    ]),
                    Row(children: <Widget>[
                      Expanded(
                          flex: 4,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Produit',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Produit invalide';
                              }
                              return null;
                            },
                          )),
                      Expanded(
                          flex: 1,
                          child: TextFormField(
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
                              _setQuantity(double.tryParse(value) ?? 0.0);
                            },
                          )),
                      Expanded(
                          flex: 1,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Prix unitaire',
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
                              _setUnitPrice(double.tryParse(value) ?? 0.0);
                            },
                          )),
                      Expanded(
                          flex: 1,
                          child: Text(
                              '${numberFormat.format(unitPrice * quantity)} €'))
                    ])
                  ],
                )),
            const VerticalDivider(),
            Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Row(children: const [
                      Expanded(
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text("Nom de l'adérent: "))),
                      Expanded(
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text('Besinet Laurie')))
                    ]),
                    const Align(
                        alignment: Alignment.topLeft,
                        child: Text('lilou@gmail.com')),
                    Row(children: [
                      const Expanded(
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text('Date: '))),
                      Expanded(
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(formatter.format(date))))
                    ]),
                    Row(children: [
                      const Expanded(
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text('Mode de paiment: '))),
                      Expanded(
                          child: DropdownButton<String>(
                        value: dropdownValue,
                        elevation: 16,
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            dropdownValue = value!;
                          });
                        },
                        items:
                            list.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ))
                    ]),
                    Center(
                        child: ElevatedButton(
                      onPressed: _validate,
                      child: const Text('Submit'),
                    ))
                  ],
                ))
          ]),
        ));
  }

  bool _validate() {
    log(_formKey.currentState.toString());
    if (_formKey.currentState!.validate()) {
      // send data to macro

      // reset form
      _formKey.currentState?.reset();
      setState(() {
        unitPrice = 0.0;
        quantity = 0.0;
      });

      return true;
    }
    return false;
  }

  void _setUnitPrice(unitPrice) {
    setState(() {
      this.unitPrice = unitPrice;
    });
  }

  void _setQuantity(quantity) {
    setState(() {
      this.quantity = quantity;
    });
  }
}
