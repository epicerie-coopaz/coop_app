import 'package:coopaz_app/auth.dart';
import 'package:coopaz_app/conf.dart';
import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/supplier.dart';
import 'package:coopaz_app/podo/units.dart';
import 'package:coopaz_app/ui/screens/home/screen_home.dart';
import 'package:flutter/material.dart';
import 'package:coopaz_app/logger.dart';

import 'dao/data_access.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    log('Init AuthManager...');

    var conf = Conf();

    var authManager = AuthManager(conf: conf);
    await authManager.init();
    await authManager.getRefreshToken();

    var memberDao = GoogleSheetDao<Member>(
      googleSheetUrlApi: conf.urls.googleSheetsApi,
      spreadSheetId: conf.spreadSheetId,
      authManager: authManager,
      sheetName: 'ImportMembres',
      range: '!A:D',
      mapping: (l) => Member(
          name: l[0].trim(),
          email: l[1].trim(),
          phone: l[2].trim(),
          score: double.tryParse(l[3].trim()) ?? double.nan),
      filter: (l) => l.length >= 4 && l[0].trim() != '',
    );

    var productDao = GoogleSheetDao<Product>(
      googleSheetUrlApi: conf.urls.googleSheetsApi,
      spreadSheetId: conf.spreadSheetId,
      authManager: authManager,
      sheetName: 'produits',
      range: '!A3:S',
      mapping: (l) {
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
      },
      filter: (l) => l.length > 11,
    );

    var supplier = GoogleSheetDao<Supplier>(
      googleSheetUrlApi: conf.urls.googleSheetsApi,
      spreadSheetId: conf.spreadSheetId,
      authManager: authManager,
      sheetName: 'fournisseurs',
      range: '!A3:J',
      mapping: (l) => Supplier(
        name: l[0].trim(),
        reference: l[1].trim(),
        address: l[2].trim(),
        postalCode: l[3].trim(),
        city: l[4].trim(),
        activityType: l[5].trim(),
        contactName: l[7].trim(),
        email: l[8].trim(),
        phone: l[9].trim(),
      ),
      filter: (l) => l.length > 10,
    );

    var orderDao = OrderDao(
        googleAppsScriptUrlApi: conf.urls.googleAppsScriptApi,
        appsScriptId: conf.appsScriptId,
        authManager: authManager);

    log('Starting Coopaz app...');
    runApp(CoopazApp(
      memberDao: memberDao,
      orderDao: orderDao,
      productDao: productDao,
    ));
    log('App started !');
  } catch (e, s) {
    runApp(MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Erreur lors du démarrage !'),
        ),
        body: ListView(
          children: [Text(e.toString()), const Divider(), Text(s.toString())],
        ),
      ),
      debugShowCheckedModeBanner: false,
    ));
  }
}
