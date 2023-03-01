import 'package:coopaz_app/podo/supplier.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SupplierList extends StatefulWidget {
  const SupplierList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SupplierList();
  }
}

class _SupplierList extends State<SupplierList> {
  Map<String, int> toggleSorts = {
    "name": 1,
    "reference": 1,
    "address": 1,
    "postalCode": 1,
    "city": 1,
    "activityType": 1,
    "contactName": 1,
    "email": 1,
    "phone": 1,
  };
  int Function(Supplier, Supplier) supplierCompare =
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, model, child) {
      var styleHeaders = Theme.of(context)
          .primaryTextTheme
          .titleLarge
          ?.apply(color: Theme.of(context).colorScheme.primary);
      var styleBody = Theme.of(context).textTheme.bodyMedium;

      List<Supplier> suppliersSorted = model.suppliers.toList();
      suppliersSorted.sort(supplierCompare);

      return Column(
        children: [
          Expanded(
              flex: 0,
              child: Row(children: [
                Expanded(
                    flex: 3,
                    child: TextButton(
                      child: Text('Nom', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('name', toggleSorts);
                        setState(() {
                          supplierCompare = (a, b) =>
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
                      child: Text('Ref.', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('reference', toggleSorts);
                        setState(() {
                          supplierCompare = (a, b) =>
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
                      child: Text('Addr.', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('address', toggleSorts);
                        setState(() {
                          supplierCompare = (a, b) =>
                              a.address
                                  .toLowerCase()
                                  .compareTo(b.address.toLowerCase()) *
                              sortCoef;
                          toggleSorts = resetCoef('address', toggleSorts);
                        });
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text('Code', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('postalCode', toggleSorts);
                        setState(() {
                          supplierCompare = (a, b) =>
                              a.postalCode
                                  .toLowerCase()
                                  .compareTo(b.postalCode.toLowerCase()) *
                              sortCoef;
                          toggleSorts = resetCoef('postalCode', toggleSorts);
                        });
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text('Ville', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('city', toggleSorts);
                        setState(() {
                          supplierCompare = (a, b) =>
                              a.city
                                  .toLowerCase()
                                  .compareTo(b.city.toLowerCase()) *
                              sortCoef;
                          toggleSorts = resetCoef('city', toggleSorts);
                        });
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text('Activité', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('activityType', toggleSorts);
                        setState(() {
                          supplierCompare = (a, b) =>
                              a.activityType
                                  .toLowerCase()
                                  .compareTo(b.activityType.toLowerCase()) *
                              sortCoef;
                          toggleSorts = resetCoef('activityType', toggleSorts);
                        });
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text('Contact', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('contactName', toggleSorts);
                        setState(() {
                          supplierCompare = (a, b) =>
                              a.contactName
                                  .toLowerCase()
                                  .compareTo(b.contactName.toLowerCase()) *
                              sortCoef;
                          toggleSorts = resetCoef('contactName', toggleSorts);
                        });
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text('email', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('email', toggleSorts);
                        setState(() {
                          supplierCompare =
                              (a, b) => a.email.compareTo(b.email) * sortCoef;
                          toggleSorts = resetCoef('email', toggleSorts);
                        });
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text('Tel.', style: styleHeaders),
                      onPressed: () {
                        int sortCoef = getSortCoef('phone', toggleSorts);
                        setState(() {
                          supplierCompare =
                              (a, b) => a.phone.compareTo(b.phone) * sortCoef;
                          toggleSorts = resetCoef('phone', toggleSorts);
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
                children: suppliersSorted.map((p) {
                  return Column(children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 3, child: Text(p.name, style: styleBody)),
                        Expanded(
                            flex: 1,
                            child: Text(p.reference, style: styleBody)),
                        Expanded(
                            flex: 1, child: Text(p.address, style: styleBody)),
                        Expanded(
                            flex: 1,
                            child: Text(p.postalCode, style: styleBody)),
                        Expanded(
                            flex: 1, child: Text(p.city, style: styleBody)),
                        Expanded(
                            flex: 1,
                            child: Text(p.activityType, style: styleBody)),
                        Expanded(
                            flex: 1,
                            child: Text(p.contactName, style: styleBody)),
                        Expanded(
                            flex: 1, child: Text(p.email, style: styleBody)),
                        Expanded(
                            flex: 1, child: Text(p.phone, style: styleBody)),
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
