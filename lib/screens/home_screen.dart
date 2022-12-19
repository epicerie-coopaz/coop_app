import 'package:coopaz_app/auth.dart';
import 'package:coopaz_app/conf.dart';
import 'package:coopaz_app/screens/cash_register/cash_register_screen.dart';
import 'package:coopaz_app/screens/members_screen.dart';
import 'package:coopaz_app/screens/products_screen.dart';
import 'package:flutter/material.dart';

import 'package:coopaz_app/logger.dart';

class CoopazApp extends StatelessWidget {
  const CoopazApp({super.key, required this.conf, required this.authManager});
  final AuthManager authManager;
  final Conf conf;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coopaz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(
        conf: conf,
        authManager: authManager,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.conf, required this.authManager});

  final AuthManager authManager;
  final Conf conf;

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
                        conf: conf, authManager: authManager),
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
                          ProductsScreen(conf: conf, authManager: authManager),
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
                      builder: (context) =>
                          MembersScreen(conf: conf, authManager: authManager),
                    ),
                  );
                },
                style: buttonStyle,
                child: const Text('Adhérents')),
          ],
        )));
  }
}
