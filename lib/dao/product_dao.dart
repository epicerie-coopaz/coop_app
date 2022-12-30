import 'dart:convert';

import 'package:coopaz_app/dao/data_access.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/units.dart';
import 'package:http/http.dart' as http;

class ProductDao extends GoogleSheetDao {
  ProductDao(
      {required super.googleSheetUrlApi,
      required super.spreadSheetId,
      required super.authManager});

  Future<List<Product>> getProducts() async {
    final response = await http.get(
        Uri.parse(
            "$googleSheetUrlApi/$spreadSheetId/values/'produits'!A3:S?majorDimension=ROWS&prettyPrint=false"),
        headers: {
          "Accept": "application/json",
          'Authorization': 'Bearer ${await authManager.getAccessToken()}',
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
        } else if (unitString == 'litre' || unitString == 'litres') {
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
