import 'package:coopaz_app/dao/member_dao.dart';
import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/dao/product_dao.dart';
import 'package:coopaz_app/state/cash_register.dart';
import 'package:coopaz_app/ui/screens/cash_register/screen_cash_register.dart';
import 'package:coopaz_app/ui/screens/members/screen_members.dart';
import 'package:coopaz_app/ui/screens/products/screen_products.dart';
import 'package:coopaz_app/state/app_model.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => CashRegisterModel(),
        ),
      ],
      builder: (context, child) {
        return MaterialApp(
          title: 'Coopaz',
          theme: ThemeData(
              colorScheme: const ColorScheme(
                brightness: Brightness.light,
                primary: Color(0xFF4B6700),
                onPrimary: Color(0xFFFFFFFF),
                primaryContainer: Color.fromARGB(255, 225, 233, 199),
                onPrimaryContainer: Color(0xFF141F00),
                secondary: Color(0xFF984800),
                onSecondary: Color(0xFFFFFFFF),
                secondaryContainer: Color(0xFFFFDBC8),
                onSecondaryContainer: Color(0xFF321300),
                tertiary: Color.fromARGB(255, 109, 117, 90),
                onTertiary: Color(0xFF4B6700),
                tertiaryContainer: Color(0xFFFFE169),
                onTertiaryContainer: Color(0xFF221B00),
                error: Color(0xFFBA1A1A),
                errorContainer: Color(0xFFFFDAD6),
                onError: Color(0xFFFFFFFF),
                onErrorContainer: Color(0xFF410002),
                background: Color(0xFFFEFCF4),
                onBackground: Color(0xFF1B1C17),
                surface: Color(0xFFFEFCF4),
                onSurface: Color(0xFF1B1C17),
                surfaceVariant: Color(0xFFE2E4D4),
                onSurfaceVariant: Color(0xFF45483C),
                outline: Color(0xFF76786B),
                onInverseSurface: Color(0xFFF2F1E9),
                inverseSurface: Color(0xFF30312C),
                inversePrimary: Color(0xFFA7D642),
                shadow: Color(0xFF000000),
                surfaceTint: Color(0xFF4B6700),
              ),
              useMaterial3: true),
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
              ),
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
              child: const Text('Caisse',
                  textScaleFactor: 2),
            ),
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
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        minimumSize: const Size(200, 200)),
                child: const Text('Produits',
                  textScaleFactor: 2)),
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
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        minimumSize: const Size(200, 200)),
                child: const Text(
                  'Adhérents',
                  textScaleFactor: 2)),
          ],
        )));
  }
}
