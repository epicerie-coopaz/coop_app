import 'dart:convert';

import 'package:coopaz_app/constants.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/units.dart';
import 'package:coopaz_app/secrets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductsScreen> {
  final String title = 'Produits';

  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    log('Init screen $title...');
    super.initState();
    futureProducts = fetchProducts();
    log('Init screen $title finish');
  }

  @override
  Widget build(BuildContext context) {
    log('Build screen $title');

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: FutureBuilder<List<Product>>(
          future: futureProducts,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var styleHeaders = Theme.of(context)
                  .primaryTextTheme
                  .titleMedium
                  ?.apply(color: Colors.blue);
              return Scrollbar(
                  child: ListView(children: [
                DataTable(
                  columns: const [
                    'Désignation',
                    'Nom',
                    'Famille',
                    'Fournisseur',
                    'Unité',
                    'Code barres',
                    'Ref.',
                    'Acheteur',
                    'Prix',
                    'Stock'
                  ]
                      .map((e) => DataColumn(
                            label: Expanded(
                              child: Text(
                                e,
                                style: styleHeaders,
                              ),
                            ),
                          ))
                      .toList(),
                  rows: snapshot.data!.map((p) {
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(p.designation)),
                        DataCell(Text(p.name)),
                        DataCell(Text(p.family)),
                        DataCell(Text(p.supplier)),
                        DataCell(Text(p.unit.name)),
                        DataCell(Text(p.barreCode)),
                        DataCell(Text(p.reference)),
                        DataCell(Text(p.buyer)),
                        DataCell(Text('${p.price}€')),
                        DataCell(Text(p.stock.toString())),
                      ],
                    );
                  }).toList(),
                )
              ])); //Text(snapshot.data!.title);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ));
  }

  Future<List<Product>> fetchProducts() async {
    var googleApiKey = await getApiKey();
    final response = await http.get(
        Uri.parse(
            "$googleApiUrl/$googleSpreadsheetId/values/'produits'!A3:S?majorDimension=ROWS&prettyPrint=false&key=$googleApiKey"),
        headers: {
          "Accept": "application/json",
        });

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      List<List<String>> values = List<dynamic>.from(body['values'])
          .map((e) => List<String>.from(e))
          .toList();
      var products = values.where((element) {
        var isOk = element.length > 11;
        if (!isOk) {
          log('Bad line: $element');
        }
        return isOk;
      }).map((l) {
        Units unit;
        var unitString = l[4].trim().toLowerCase();
        if (unitString == 'kilo') {
          unit = Units.kg;
        } else if (unitString == 'litre') {
          unit = Units.liter;
        } else {
          unit = Units.piece;
        }

        var product = Product(
            designation: l[0].trim(),
            name: l[1].trim(),
            family: l[2].trim(),
            supplier: l[3].trim(),
            unit: unit,
            barreCode: l[5].trim(),
            reference: l[7].trim(),
            buyer: l[8].trim(),
            price: double.tryParse(l[9].replaceAll('€', '').trim()) ?? 0.0,
            stock: double.tryParse(l[11].trim()) ?? 0.0);

        return product;
      }).toList();

      return products;
    } else {
      log('Failed to load products: [${response.statusCode}] ${response.body}');
      throw Exception(
          'Failed to load products: [${response.statusCode}] ${response.body}');
    }
  }
}
