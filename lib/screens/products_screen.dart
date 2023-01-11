import 'package:coopaz_app/dao/product_dao.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/utils.dart';
import 'package:coopaz_app/state/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key, required this.productDao});

  final ProductDao productDao;

  final String title = 'Produits';

  @override
  Widget build(BuildContext context) {
    log('Build screen $title');

    var styleHeaders = Theme.of(context)
        .primaryTextTheme
        .titleLarge
        ?.apply(color: Theme.of(context).colorScheme.primary);
    var styleBody = Theme.of(context).textTheme.bodyMedium;

    return Consumer<AppModel>(builder: (context, model, child) {
      return Scaffold(
          appBar: AppBar(
            title: Row(children: [
              Text(title),
              const Spacer(),
              IconButton(
                  onPressed: () async {
                    model.products = await productDao.getProducts();
                  },
                  icon: const Icon(Icons.refresh))
            ]),
          ),
          body: Column(
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
                              child: Text(
                                e.a,
                                style: styleHeaders,
                              ),
                            ),
                          )
                          .toList())),
              const Divider(
                thickness: 2,
              ),
              Expanded(
                  flex: 1,
                  child: ListView(
                    addAutomaticKeepAlives: false,
                    children: model.products.map((p) {
                      return Column(children: [
                        Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Text(p.designation, style: styleBody)),
                            Expanded(
                                flex: 1, child: Text(p.name, style: styleBody)),
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
                                child: Text('${p.price}€', style: styleBody)),
                            Expanded(
                                flex: 1,
                                child:
                                    Text(p.stock.toString(), style: styleBody)),
                          ],
                        ),
                        const Divider()
                      ]);
                    }).toList(),
                  ))
            ],
          ));
    });
  }
}
