import 'package:coopaz_app/dao/member_dao.dart';
import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/dao/product_dao.dart';
import 'package:coopaz_app/screens/cash_register/cash_register_screen.dart';
import 'package:coopaz_app/screens/members_screen.dart';
import 'package:coopaz_app/screens/products_screen.dart';
import 'package:coopaz_app/state/model.dart';
import 'package:flutter/material.dart';

import 'package:coopaz_app/logger.dart';
import 'package:provider/provider.dart';

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
    return ChangeNotifierProvider(
      create: (context) => AppModel(),
      builder: (context, child) {
        return MaterialApp(
          title: 'Coopaz',
          theme: ThemeData(
            //backgroundColor: const Color(0xFFFEFCF4),
            colorSchemeSeed: Color.fromARGB(255, 255, 174, 52),
            //useMaterial3: true
          ),
          home: HomeScreen(
              memberDao: memberDao, productDao: productDao, orderDao: orderDao),
          debugShowCheckedModeBanner: false,
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: const Color(0xff00BCD1),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: const Size(200, 200),
              ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
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
              child: const Text('Caisse'),
            ),
            ElevatedButton(
                onPressed: () {
                  log('Reception Clicked !');
                },
                style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        minimumSize: const Size(200, 200))
                    .copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                child: const Text('Reception')),
            ElevatedButton(
                onPressed: () {
                  log('Products Clicked !');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductsScreen(productDao: productDao),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        minimumSize: const Size(200, 200))
                    .copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                child: const Text('Produits')),
            ElevatedButton(
                onPressed: () {
                  log('Members Clicked !');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MembersScreen(memberDao: memberDao),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        minimumSize: const Size(200, 200))
                    .copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                child: const Text('Adhérents')),
          ],
        )));
  }
}
