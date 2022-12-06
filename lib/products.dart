import 'dart:convert';
import 'dart:ffi';

import 'package:coopaz_app/constants.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/secrets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _MyAppState();
}

class _MyAppState extends State<ProductsScreen> {
  final String title = 'Produits';

  late Future<List<String>> futureProducts;

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
      body: FutureBuilder<List<String>>(
            future: futureProducts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var childs = snapshot.data!.map((e) => Center(child:Text(e))).toList();
                return       GridView.count(
                  crossAxisCount: 9,
                  children: childs,
                ); //Text(snapshot.data!.title);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          )
    );
  }

  Future<List<String>> fetchProducts() async {
    var googleApiKey = await getApiKey();
    final response = await http.get(
        Uri.parse(
            "$googleApiUrl/$googleSpreadsheetId/values/'produits'!A2:S2?key=$googleApiKey"),
        headers: {
          "Accept": "application/json",
        });

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      var values = List<String>.from(body['values'][0]);
      return values;
    } else {
      log('Fails to fetch products: [${response.statusCode}] ${response.body}');
      throw Exception('Failed to load products');
    }
  }
}
