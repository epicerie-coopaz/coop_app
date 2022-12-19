import 'dart:convert';

import 'package:coopaz_app/conf.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/units.dart';
import 'package:coopaz_app/podo/utils.dart';
import 'package:coopaz_app/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductsScreen extends StatefulWidget {
  const ProductsScreen(
      {super.key, required this.conf, required this.authManager});

  final AuthManager authManager;
  final Conf conf;

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
              var styleBody = Theme.of(context)
                  .primaryTextTheme
                  .bodyMedium
                  ?.apply(color: Colors.black);
              return Column(
                children: [
                  Expanded(
                      flex: 0,
                      child: Row(
                          children: [
                        Pair('Désignation', 3),
                        Pair('Nom', 1),
                        Pair('Famille', 1),
                        Pair('Fournisseur', 1),
                        Pair('Unité', 1),
                        Pair('Code barres', 1),
                        Pair('Ref.', 1),
                        Pair('Acheteur', 1),
                        Pair('Prix', 1),
                        Pair('Stock', 1)
                      ]
                              .map(
                                (e) => Expanded(
                                  flex: e.b,
                                  child: Text(
                                    e.a,
                                    style: styleHeaders,
                                  ),
                                ),
                              )
                              .toList())),
                  const Divider(
                    thickness: 2,
                  ),
                  Expanded(
                      flex: 1,
                      child: ListView(
                        addAutomaticKeepAlives: false,
                        children: snapshot.data!.map((p) {
                          return Column(children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child:
                                        Text(p.designation, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.name, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.family, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.supplier, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.unit.name, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.barreCode, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.reference, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.buyer, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child:
                                        Text('${p.price}€', style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.stock.toString(),
                                        style: styleBody)),
                              ],
                            ),
                            const Divider()
                          ]);
                        }).toList(),
                      ))
                ],
              ); //Text(snapshot.data!.title);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ));
  }

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(
        Uri.parse(
            "${widget.conf.urls.googleSheetsApi}/${widget.conf.spreadSheetId}/values/'produits'!A3:S?majorDimension=ROWS&prettyPrint=false"),
        headers: {
          "Accept": "application/json",
          'Authorization':
              'Bearer ${await widget.authManager.getAccessToken()}',
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
