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

  late Future<List<String>> products;

  @override
  void initState() {
    log('Init screen $title...');
    super.initState();
    products = fetchProducts();
    log('Init screen $title finish');
  }

  @override
  Widget build(BuildContext context) {
    log('Build screen $title');

    List<Widget> childs = List.from([
      const Center(
          child: Text(
        'Nom',
      )),
      const Center(
          child: Text(
        'Famille',
      )),
      const Center(
          child: Text(
        'Fournisseur',
      )),
      const Center(
          child: Text(
        'Unité',
      )),
      const Center(
          child: Text(
        'CaB',
      )),
      const Center(
          child: Text(
        'Reference',
      )),
      const Center(
          child: Text(
        'Acheteur',
      )),
      const Center(
          child: Text(
        'Prix',
      )),
      const Center(
          child: Text(
        'Stock',
      ))
    ]);

    childs.addAll(List.generate(100, (index) {
      return Center(
        child: Text(
          'Item $index',
        ),
      );
    }));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GridView.count(
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: 9,
        // Generate 100 widgets that display their index in the List.
        children: childs,
      ),
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
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return [response.body];
    } else {
      log('Fails to fetch products: [${response.statusCode}] ${response.body}');
      throw Exception('Failed to load products');
    }
  }
}
