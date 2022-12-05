import 'package:coopaz_app/cash_register.dart';
import 'package:coopaz_app/products.dart';
import 'package:flutter/material.dart';

import 'logger.dart';

void main() {
  log('Starting Coopaz app...');
  runApp(const CoopazApp());
  log('App started !');
}

class CoopazApp extends StatelessWidget {
  const CoopazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coopaz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                    builder: (context) => const CashRegisterScreen(),
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
                      builder: (context) => const ProductsScreen(),
                    ),
                  );
                },
                style: buttonStyle,
                child: const Text('Produits')),
            TextButton(
                onPressed: () {
                  log('Adherents Clicked !');
                },
                style: buttonStyle,
                child: const Text('Adhérents')),
          ],
        )));
  }
}
