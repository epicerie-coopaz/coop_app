import 'package:coopaz_app/dao/product_dao.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/utils.dart';
import 'package:flutter/material.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, required this.productDao});

  final ProductDao productDao;

  @override
  State<ProductsScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductsScreen> {
  final String title = 'Produits';

  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    log('Init screen $title...');
    super.initState();
    futureProducts = widget.productDao.getProducts();
    log('Init screen $title finish');
  }

  @override
  Widget build(BuildContext context) {
    log('Build screen $title');

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: FutureBuilder<List<Product>>(
          future: futureProducts,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var styleHeaders = Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.apply(color: Theme.of(context).primaryColor);
              var styleBody = Theme.of(context).textTheme.bodyMedium;
              return Column(
                children: [
                  Expanded(
                      flex: 0,
                      child: Row(
                          children: [
                        Pair('Désignation', 3),
                        Pair('Nom', 1),
                        Pair('Famille', 1),
                        Pair('Fournisseur', 1),
                        Pair('Unité', 1),
                        Pair('Code barres', 1),
                        Pair('Ref.', 1),
                        Pair('Acheteur', 1),
                        Pair('Prix', 1),
                        Pair('Stock', 1)
                      ]
                              .map(
                                (e) => Expanded(
                                    flex: e.b,
                                    child: Title(
                                      color: Theme.of(context).primaryColor,
                                      child: Text(
                                        e.a,
                                      ),
                                    )),
                              )
                              .toList())),
                  const Divider(
                    thickness: 2,
                  ),
                  Expanded(
                      flex: 1,
                      child: ListView(
                        addAutomaticKeepAlives: false,
                        children: snapshot.data!.map((p) {
                          return Column(children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child:
                                        Text(p.designation, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.name, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.family, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.supplier, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.unit.unitAsString,
                                        style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.barreCode, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.reference, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.buyer, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child:
                                        Text('${p.price}€', style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.stock.toString(),
                                        style: styleBody)),
                              ],
                            ),
                            const Divider()
                          ]);
                        }).toList(),
                      ))
                ],
              ); //Text(snapshot.data!.title);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ));
  }
}
