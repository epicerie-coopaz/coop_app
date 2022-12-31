import 'package:coopaz_app/dao/member_dao.dart';
import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/dao/product_dao.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/product_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:coopaz_app/logger.dart';

class CashRegisterScreen extends StatefulWidget {
  const CashRegisterScreen(
      {super.key,
      required this.orderDao,
      required this.memberDao,
      required this.productDao});

  final OrderDao orderDao;
  final MemberDao memberDao;
  final ProductDao productDao;

  @override
  State<CashRegisterScreen> createState() => _CashRegisterScreenState();
}

class _CashRegisterScreenState extends State<CashRegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String title = 'Caisse';
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  static const List<String> paymentMethodList = <String>[
    'CB',
    'Cheque',
    'Virement'
  ];
  NumberFormat numberFormat = NumberFormat('#,##0.00');

  late Future<List<Member>> futureMembers;
  late Future<List<Product>> futureProducts;

  //Form data
  String paymentmethodSelected = paymentMethodList.first;

  List<ProductLine> productLines = [ProductLine()];
  Member? selectedMember;

  @override
  initState() {
    log('Init screen $title...');
    super.initState();
    log('Get members...');
    futureMembers = widget.memberDao.getMembers();
    log('Get products...');
    futureProducts = widget.productDao.getProducts();
    log('Init screen $title finish');
  }

  @override
  Widget build(BuildContext context) {
    log('build screen $title');

    var styleHeaders = Theme.of(context)
        .primaryTextTheme
        .titleLarge
        ?.apply(color: Colors.blue);

    List<Row> productLineWidgets = _createProductLineWidgets();

    double total = productLines
        .map((e) =>
            (double.tryParse(e.qty ?? '0') ?? 0.0) *
            (double.tryParse(e.unitPrice ?? '0') ?? 0.0))
        .fold(0.0, (prev, e) => prev + e);

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
                            'Produit',
                            style: styleHeaders,
                          )),
                      Expanded(
                          flex: 2,
                          child: Text(
                            'Quantité',
                            style: styleHeaders,
                          )),
                      Expanded(
                          flex: 2,
                          child: Text(
                            'Prix unitaire',
                            style: styleHeaders,
                          )),
                      Expanded(
                          flex: 2,
                          child: Text(
                            'Unité',
                            style: styleHeaders,
                          )),
                      Expanded(
                          flex: 2,
                          child: Text(
                            'Total',
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
                    Row(children: [
                      Expanded(
                          child: Autocomplete<Member>(
                        displayStringForOption: (Member m) =>
                            '${m.name} : ${m.email}',
                        optionsBuilder:
                            (TextEditingValue textEditingValue) async {
                          if (textEditingValue.text == '') {
                            return const Iterable<Member>.empty();
                          }
                          return (await futureMembers).where((Member m) {
                            return m
                                .toString()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (m) {
                          setState(() {
                            selectedMember = m;
                          });
                        },
                      )),
                    ]),
                    Row(children: [
                      const Expanded(
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text('Total: '))),
                      Expanded(
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text('${total.toStringAsFixed(2)}€')))
                    ]),
                    Row(children: [
                      const Expanded(
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text('Mode de paiment: '))),
                      Expanded(
                          child: DropdownButton<String>(
                        value: paymentmethodSelected,
                        elevation: 16,
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            paymentmethodSelected = value!;
                          });
                        },
                        items: paymentMethodList
                            .map<DropdownMenuItem<String>>((String value) {
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

  _sendForm() async {
    // send data to macro
    await widget.orderDao
        .createOrder(selectedMember?.email ?? '', productLines);
    // reset form
    _formKey.currentState?.reset();
    setState(() {
      productLines = [ProductLine()];
    });
  }

  List<Row> _createProductLineWidgets() {
    List<Row> products = [];
    for (var entry in productLines.asMap().entries) {
      var product = _createProductLineWidget(entry.key, entry.value);
      products.add(product);
    }
    return products;
  }

  Row _createProductLineWidget(int index, ProductLine product) {
    var total = '';
    double? unitPrice = double.tryParse(product.unitPrice ?? '');
    double? qty = double.tryParse(product.qty ?? '');
    if (unitPrice != null && qty != null) {
      total = '${numberFormat.format(unitPrice * qty)} €';
    }

    var productWidget = Row(children: <Widget>[
      Expanded(
          flex: 8,
          child: Autocomplete<Product>(
            displayStringForOption: (Product p) => p.designation,
            optionsBuilder: (TextEditingValue textEditingValue) async {
              if (textEditingValue.text == '') {
                return const Iterable<Product>.empty();
              }
              return (await futureProducts).where((Product p) {
                return p
                    .toString()
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (p) {
              setState(() {
                productLines[index] = ProductLine(
                    name: p.designation,
                    unit: p.unit.unitAsString,
                    unitPrice: p.price.toStringAsFixed(2));
              });
            },
          )),
      Expanded(
          flex: 2,
          child: TextFormField(
            controller: TextEditingController(text: product.qty ?? '')
              ..selection =
                  TextSelection.collapsed(offset: (product.qty ?? '').length),
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
              product.qty = value;
              setState(() {
                productLines[index] = product;
              });
            },
          )),
      Expanded(flex: 2, child: Text(product.unitPrice ?? '-')),
      Expanded(flex: 2, child: Text(product.unit ?? '-')),
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
