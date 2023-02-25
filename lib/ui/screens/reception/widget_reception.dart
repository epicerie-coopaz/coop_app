import 'package:coopaz_app/ui/screens/reception/widget_supplier_autocomplete.dart';
import 'package:flutter/material.dart';

class Reception extends StatefulWidget {
  const Reception({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Reception();
  }
}

class _Reception extends State<Reception> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Column(children: [
          Row(
            children: const [Expanded(child: Text("Fournisseur:")), Expanded(child: SupplierAutocomplete())],
          )
        ]),
      ),
      Expanded(
        child: Column(children: [
          Row(
            children: const [Expanded(child: Text("Bon de livraison"))],
          )
        ]),
      )
    ]);
  }
}
