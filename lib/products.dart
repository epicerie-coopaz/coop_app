import 'package:flutter/material.dart';

import 'logger.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  final String title = 'Produits';

  @override
  Widget build(BuildContext context) {
    log('build screen $title');

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
}
