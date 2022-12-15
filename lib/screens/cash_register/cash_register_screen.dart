import 'package:coopaz_app/podo/product_line.dart';
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

  List<ProductLine> productLines = [ProductLine()];

  @override
  Widget build(BuildContext context) {
    log('build screen $title');

    var styleHeaders = Theme.of(context)
        .primaryTextTheme
        .titleLarge
        ?.apply(color: Colors.blue);

    List<Widget> productLineWidgets = _createProductLineWidgets();

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
                          flex: 8,
                          child: Text(
                            "Produit",
                            style: styleHeaders,
                          )),
                      Expanded(
                          flex: 2,
                          child: Text(
                            "Quantité",
                            style: styleHeaders,
                          )),
                      Expanded(
                          flex: 2,
                          child: Text(
                            "Prix unitaire",
                            style: styleHeaders,
                          )),
                      Expanded(
                          flex: 2,
                          child: Text(
                            "Total",
                            style: styleHeaders,
                          )),
                      Expanded(flex: 1, child: Container()),
                    ]),
                    Column(children: productLineWidgets),
                    Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            log('+ pressed');
                            _validateAll();
                            productLines.add(ProductLine());
                            setState(() {
                              productLines = productLines;
                            });
                          },
                          child: const Icon(Icons.add),
                        ))
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
                      onPressed: () {
                        if (_validateAll()) {
                          log('Send form !!!');
                          _sendForm();
                        } else {
                          log('Form invalid');
                        }
                      },
                      child: const Text('Valider'),
                    ))
                  ],
                ))
          ]),
        ));
  }

  bool _validateAll() {
    log(_formKey.currentState.toString());
    if (_formKey.currentState!.validate()) {
      return true;
    }
    return false;
  }

  bool _sendForm() {
    if (_formKey.currentState!.validate()) {
      // send data to macro

      // reset form
      _formKey.currentState?.reset();
      setState(() {
        productLines = [ProductLine()];
      });

      return true;
    }
    return false;
  }

  List<Widget> _createProductLineWidgets() {
    List<Widget> products = [];
    for (var entry in productLines.asMap().entries) {
      var product = _createProductLineWidget(entry.key, entry.value);
      products.add(product);
    }
    return products;
  }

  Widget _createProductLineWidget(int index, ProductLine product) {
    var total = '';
    if (product.unitPrice != null && product.qty != null) {
      total = '${numberFormat.format(product.unitPrice! * product.qty!)} €';
    }
    var productWidget = Row(children: <Widget>[
      Expanded(
          flex: 8,
          child: TextFormField(
            initialValue: product.name,
            decoration: const InputDecoration(
              hintText: 'Produit',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Produit invalide';
              }
              return null;
            },
            onChanged: (String value) {
              product.name = value;
              setState(() {
                productLines[index] = product;
              });
            },
          )),
      Expanded(
          flex: 2,
          child: TextFormField(
            initialValue: '${product.qty ?? ""}',
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
              product.qty = double.tryParse(value) ?? 0.0;
              setState(() {
                productLines[index] = product;
              });
            },
          )),
      Expanded(
          flex: 2,
          child: TextFormField(
            initialValue: '${product.unitPrice ?? ""}',
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
              product.unitPrice = double.tryParse(value) ?? 0.0;
              setState(() {
                productLines[index] = product;
              });
            },
          )),
      Expanded(flex: 2, child: Text(total)),
      Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              log('Delete line pressed');
              setState(() {
                productLines.remove(product);
              });
            },
            child: const Icon(Icons.delete),
          ))
    ]);

    return productWidget;
  }
}
