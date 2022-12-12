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

  //Form data
  String dropdownValue = list.first;
  DateTime date = DateTime.now();

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
                                return 'Please enter some text';
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
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          )),
                      const Expanded(
                          flex: 1,
                          child: Text('18.0 €')),
                      const Expanded(
                          flex: 1,
                          child: Text('126.0 €'))
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
                      onPressed: validate,
                      child: const Text('Submit'),
                    ))
                  ],
                ))
          ]),
        ));
  }

  bool validate() {
    log(_formKey.currentState.toString());
    if (_formKey.currentState!.validate()) {
      // send data to macro

      // reset form
      _formKey.currentState?.reset();

      return true;
    }
    return false;
  }
}
