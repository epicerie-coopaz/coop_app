import 'package:coopaz_app/podo/supplier.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/ui/common_widgets/widget_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SupplierList extends StatelessWidget {
  SupplierList({super.key});

  final Map<String, ColumnDef<Supplier>> columnsDef = {
    "name": ColumnDef(
        flex: 1,
        name: 'Nom',
        sort: (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        value: (a) => a.name),
    "reference": ColumnDef(
        flex: 1,
        name: 'Ref.',
        sort: (a, b) =>
            a.reference.toLowerCase().compareTo(b.reference.toLowerCase()),
        value: (a) => a.reference),
    "address": ColumnDef(
        flex: 1,
        name: 'Addr.',
        sort: (a, b) =>
            a.address.toLowerCase().compareTo(b.address.toLowerCase()),
        value: (a) => a.address),
    "postalCode": ColumnDef(
        flex: 1,
        name: 'Code',
        sort: (a, b) =>
            a.postalCode.toLowerCase().compareTo(b.postalCode.toLowerCase()),
        value: (a) => a.postalCode),
    "city": ColumnDef(
        flex: 1,
        name: 'Ville',
        sort: (a, b) => a.city.toLowerCase().compareTo(b.city.toLowerCase()),
        value: (a) => a.city),
    "activityType": ColumnDef(
        flex: 1,
        name: 'Activité',
        sort: (a, b) => a.activityType
            .toLowerCase()
            .compareTo(b.activityType.toLowerCase()),
        value: (a) => a.activityType),
    "contactName": ColumnDef(
        flex: 1,
        name: 'Contact',
        sort: (a, b) =>
            a.contactName.toLowerCase().compareTo(b.contactName.toLowerCase()),
        value: (a) => a.contactName),
    "email": ColumnDef(
        flex: 1,
        name: 'Email',
        sort: (a, b) => a.email.toLowerCase().compareTo(b.email.toLowerCase()),
        value: (a) => a.email),
    "phone": ColumnDef(
        flex: 1,
        name: 'Tel.',
        sort: (a, b) => a.phone.toLowerCase().compareTo(b.phone.toLowerCase()),
        value: (a) => a.phone),
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, model, child) {
      return WidgetList<Supplier>(
        columns: columnsDef,
        defaultSort: columnsDef["name"]!.sort,
        itemList: model.suppliers.toList(),
      );
    });
  }
}
