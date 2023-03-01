import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProductList();
  }
}

class _ProductList extends State<ProductList> {

  Map<String, int> toggleSorts = {
    "designation": 1,
    "name": 1,
    "family": 1,
    "supplier": 1,
    "unit": 1,
    "barreCode": 1,
    "reference": 1,
    "buyer": 1,
    "price": 1,
    "stock": 1,
  };
  int Function(Product, Product) productCompare = (a, b) =>
      a.designation.toLowerCase().compareTo(b.designation.toLowerCase());

  @override
  Widget build(BuildContext context) {

    return Consumer<AppModel>(builder: (context, model, child) {
      var styleHeaders = Theme.of(context)
          .primaryTextTheme
          .titleLarge
          ?.apply(color: Theme.of(context).colorScheme.primary);
      var styleBody = Theme.of(context).textTheme.bodyMedium;

      List<Product> productsSorted = model.products.toList();
      productsSorted.sort(productCompare);

      return Column(
        children: [
          Expanded(
              flex: 0,
              child: Row(children: [
                Expanded(
                    flex: 3,
                    child: TextButton(
                      child: Text('Désignation', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('designation', toggleSorts);
                        setState(() {
                          productCompare = (a, b) =>
                              a.designation
                                  .toLowerCase()
                                  .compareTo(b.designation.toLowerCase()) *
                              sortCoef;
                          toggleSorts = resetCoef('designation', toggleSorts);
                        });
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text('Nom', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('name', toggleSorts);
                        setState(() {
                          productCompare = (a, b) =>
                              a.name
                                  .toLowerCase()
                                  .compareTo(b.name.toLowerCase()) *
                              sortCoef;
                          toggleSorts = resetCoef('name', toggleSorts);
                        });
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text('Famille', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('family', toggleSorts);
                        setState(() {
                          productCompare = (a, b) =>
                              a.family
                                  .toLowerCase()
                                  .compareTo(b.family.toLowerCase()) *
                              sortCoef;
                          toggleSorts = resetCoef('family', toggleSorts);
                        });
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text('Fournisseur', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('supplier', toggleSorts);
                        setState(() {
                          productCompare = (a, b) =>
                              a.supplier
                                  .toLowerCase()
                                  .compareTo(b.supplier.toLowerCase()) *
                              sortCoef;
                          toggleSorts = resetCoef('supplier', toggleSorts);
                        });
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text('Code barres', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('barreCode', toggleSorts);
                        setState(() {
                          productCompare = (a, b) =>
                              a.barreCode
                                  .toLowerCase()
                                  .compareTo(b.barreCode.toLowerCase()) *
                              sortCoef;
                          toggleSorts = resetCoef('barreCode', toggleSorts);
                        });
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text('Ref.', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('reference', toggleSorts);
                        setState(() {
                          productCompare = (a, b) =>
                              a.reference
                                  .toLowerCase()
                                  .compareTo(b.reference.toLowerCase()) *
                              sortCoef;
                          toggleSorts = resetCoef('reference', toggleSorts);
                        });
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text('Acheteur', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('buyer', toggleSorts);
                        setState(() {
                          productCompare = (a, b) =>
                              a.buyer
                                  .toLowerCase()
                                  .compareTo(b.buyer.toLowerCase()) *
                              sortCoef;
                          toggleSorts = resetCoef('buyer', toggleSorts);
                        });
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text('Prix U.', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('price', toggleSorts);
                        setState(() {
                          productCompare =
                              (a, b) => a.price.compareTo(b.price) * sortCoef;
                          toggleSorts = resetCoef('price', toggleSorts);
                        });
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text('Stock', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('stock', toggleSorts);
                        setState(() {
                          productCompare =
                              (a, b) => a.stock.compareTo(b.stock) * sortCoef;
                          toggleSorts = resetCoef('stock', toggleSorts);
                        });
                      },
                    ))
              ])),
          const Divider(
            thickness: 2,
          ),
          Expanded(
              flex: 1,
              child: ListView(
                addAutomaticKeepAlives: false,
                children: productsSorted.map((p) {
                  return Column(children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text(p.designation, style: styleBody)),
                        Expanded(
                            flex: 1, child: Text(p.name, style: styleBody)),
                        Expanded(
                            flex: 1, child: Text(p.family, style: styleBody)),
                        Expanded(
                            flex: 1, child: Text(p.supplier, style: styleBody)),
                        Expanded(
                            flex: 1,
                            child: Text(p.barreCode, style: styleBody)),
                        Expanded(
                            flex: 1,
                            child: Text(p.reference, style: styleBody)),
                        Expanded(
                            flex: 1, child: Text(p.buyer, style: styleBody)),
                        Expanded(
                            flex: 1,
                            child: Text('${p.price}€/${p.unit.unitAsString}',
                                style: styleBody)),
                        Expanded(
                            flex: 1,
                            child: Text(p.stock.toString(), style: styleBody)),
                      ],
                    ),
                    const Divider()
                  ]);
                }).toList(),
              ))
        ],
      );
    });
  }
}
