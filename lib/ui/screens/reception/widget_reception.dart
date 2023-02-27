import 'package:coopaz_app/state/reception.dart';
import 'package:coopaz_app/ui/screens/reception/widget_product_autocomplete.dart';
import 'package:coopaz_app/ui/screens/reception/widget_supplier_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    ReceptionModel receptionModel = context.watch<ReceptionModel>();

    String actualPrice = '';
    String actualStock = '';
    if (receptionModel.selectedProduct != null) {
      actualPrice = '${receptionModel.selectedProduct?.price} €/${receptionModel.selectedProduct?.unit.unitAsString}';
      actualStock = '${receptionModel.selectedProduct?.stock} ${receptionModel.selectedProduct?.unit.unitAsString}';
    }


    return Row(children: [
      Expanded(flex:3,
        child: Column(children: [
          Row(
            children: const [
              Expanded(child: Text("Fournisseur:")),
              Expanded(child: SupplierAutocomplete())
            ],
          ),
          Row(
            children: const [
              Expanded(child: Text("Produit")),
              Expanded(child: Text("Prix actuel")),
              Expanded(child: Text("Stock actuel")),
              Expanded(child: Text("Prix modifé")),
              Expanded(child: Text("Stock modifié")),
              Expanded(child: Text("Reception du jour")),
            ],
          ),
          Row(
            children: [
              const Expanded(child: ProductAutocomplete()),
              Expanded(child: Text(actualPrice)),
              Expanded(child: Text(actualStock)),
              const Expanded(child: Text("-")),
              const Expanded(child: Text("-")),
              const Expanded(child: Text("-")),
            ],
          )
        ]),
      ),
      const VerticalDivider(),
      Expanded(flex:1,
        child: Column(children: [
          Row(
            children: const [Expanded(child: Text("Bon de livraison"))],
          )
        ]),
      )
    ]);
  }
}
