import 'package:coopaz_app/dao/member_dao.dart';
import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/dao/product_dao.dart';
import 'package:coopaz_app/screens/cash_register/cash_register_screen.dart';
import 'package:coopaz_app/screens/members_screen.dart';
import 'package:coopaz_app/screens/products_screen.dart';
import 'package:flutter/material.dart';

import 'package:coopaz_app/logger.dart';

class CoopazApp extends StatelessWidget {
  const CoopazApp(
      {super.key,
      required this.memberDao,
      required this.productDao,
      required this.orderDao});
  final MemberDao memberDao;
  final ProductDao productDao;
  final OrderDao orderDao;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coopaz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(
          memberDao: memberDao, productDao: productDao, orderDao: orderDao),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen(
      {super.key,
      required this.memberDao,
      required this.productDao,
      required this.orderDao});

  final MemberDao memberDao;
  final ProductDao productDao;
  final OrderDao orderDao;

  final String title = 'Logiciel Coopaz';

  final ButtonStyle buttonStyle = const ButtonStyle(
    minimumSize: MaterialStatePropertyAll(Size(200, 200)),
    backgroundColor: MaterialStatePropertyAll(Colors.blue),
    foregroundColor: MaterialStatePropertyAll(Colors.white),
    overlayColor: MaterialStatePropertyAll(Colors.green),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(title),
        ),
        body: Center(
            child: Wrap(
          spacing: 10.0, // gap between adjacent chips
          runSpacing: 10.0, // gap between lines
          children: <Widget>[
            TextButton(
              onPressed: () {
                log('Cash register Clicked !');

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CashRegisterScreen(
                        orderDao: orderDao,
                        memberDao: memberDao,
                        productDao: productDao),
                  ),
                );
              },
              style: buttonStyle,
              child: const Text('Caisse'),
            ),
            TextButton(
                onPressed: () {
                  log('Reception Clicked !');
                },
                style: buttonStyle,
                child: const Text('Reception')),
            TextButton(
                onPressed: () {
                  log('Products Clicked !');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductsScreen(productDao: productDao),
                    ),
                  );
                },
                style: buttonStyle,
                child: const Text('Produits')),
            TextButton(
                onPressed: () {
                  log('Members Clicked !');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MembersScreen(memberDao: memberDao),
                    ),
                  );
                },
                style: buttonStyle,
                child: const Text('Adhérents')),
          ],
        )));
  }
}
