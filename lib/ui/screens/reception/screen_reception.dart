import 'package:coopaz_app/dao/data_access.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/supplier.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/ui/common_widgets/loading_widget.dart';
import 'package:coopaz_app/ui/screens/reception/widget_reception.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReceptionScreen extends StatelessWidget {
  const ReceptionScreen(
      {super.key, required this.productDao, required this.supplierDao});

  final GoogleSheetDao<Product> productDao;
  final GoogleSheetDao<Supplier> supplierDao;

  final String title = 'Réception';

  @override
  Widget build(BuildContext context) {
    log('Build screen $title');

    return Consumer<AppModel>(builder: (context, model, child) {
      Widget w;
      if (model.products.isNotEmpty && model.suppliers.isNotEmpty) {
        w = const Reception();
      } else {
        productDao.get().then((p) => model.products = p);
        supplierDao.get().then((s) => model.suppliers = s);
        w = const Loading(
            text: 'Chargement de la liste des produits et fournisseurs...');
      }
      return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () async {
                    model.products = [];
                    model.suppliers = [];
                  },
                  icon: const Icon(Icons.refresh))
            ],
            title: Text(title),
          ),
          body: Container(padding: const EdgeInsets.all(12.0), child: w));
    });
  }
}
