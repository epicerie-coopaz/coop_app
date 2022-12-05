import 'package:flutter/material.dart';

import 'logger.dart';

class CashRegisterScreen extends StatelessWidget {
  const CashRegisterScreen({super.key});

  final String title = 'Caisse';

  @override
  Widget build(BuildContext context) {
    log('build cash register screen');

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: const Center(child: Text('Caisse')));
  }
}
