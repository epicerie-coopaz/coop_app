import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/ui/common_widgets/widget_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductList extends StatelessWidget {
  ProductList({super.key});

  final Map<String, ColumnDef<Product>> columnsDef = {
    "designation": ColumnDef(
        flex: 3,
        name: 'Désignation',
        sort: (a, b) =>
            a.designation.toLowerCase().compareTo(b.designation.toLowerCase()),
        value: (a) => a.designation),
    "name": ColumnDef(
        flex: 1,
        name: 'Nom',
        sort: (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        value: (a) => a.name),
    "family": ColumnDef(
        flex: 1,
        name: 'Famille',
        sort: (a, b) =>
            a.family.toLowerCase().compareTo(b.family.toLowerCase()),
        value: (a) => a.family),
    "supplier": ColumnDef(
        flex: 1,
        name: 'Fournisseur',
        sort: (a, b) =>
            a.supplier.toLowerCase().compareTo(b.supplier.toLowerCase()),
        value: (a) => a.supplier),
    "barreCode": ColumnDef(
        flex: 1,
        name: 'Code barres',
        sort: (a, b) =>
            a.barreCode.toLowerCase().compareTo(b.barreCode.toLowerCase()),
        value: (a) => a.barreCode),
    "reference": ColumnDef(
        flex: 1,
        name: 'Ref.',
        sort: (a, b) =>
            a.reference.toLowerCase().compareTo(b.reference.toLowerCase()),
        value: (a) => a.reference),
    "buyer": ColumnDef(
        flex: 1,
        name: 'Acheteur',
        sort: (a, b) => a.buyer.toLowerCase().compareTo(b.buyer.toLowerCase()),
        value: (a) => a.buyer),
    "price": ColumnDef(
        flex: 1,
        name: 'Prix',
        sort: (a, b) => a.price.compareTo(b.price),
        value: (a) => '${a.price}€/${a.unit.unitAsString}'),
    "stock": ColumnDef(
        flex: 1,
        name: 'Stock',
        sort: (a, b) => a.stock.compareTo(b.stock),
        value: (a) => a.stock.toString()),
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, model, child) {
      return WidgetList<Product>(
        columns: columnsDef,
        defaultSort: columnsDef["designation"]!.sort,
        itemList: model.products.toList(),
      );
    });
  }
}
