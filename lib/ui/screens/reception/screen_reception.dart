import 'package:coopaz_app/dao/data_access.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/podo/supplier.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/state/reception.dart';
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

    AppModel appModel = context.watch<AppModel>();

    ReceptionModel receptionModel = context.watch<ReceptionModel>();

    Widget w;
    if (appModel.products.isNotEmpty && appModel.suppliers.isNotEmpty) {
      w = const Reception();
    } else {
      productDao.get().then((p) => appModel.products = p);
      supplierDao.get().then((s) => appModel.suppliers = s);
      w = const Loading(
          text: 'Chargement de la liste des produits et fournisseurs...');
    }
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                focusNode: FocusNode(skipTraversal: true),
                onPressed: () async {
                  appModel.zoomText = appModel.zoomText - appModel.zoomStep;
                  log(appModel.zoomText.toString());
                },
                icon: const Icon(Icons.text_decrease),
                tooltip: 'Diminuer la taille du texte'),
            IconButton(
                focusNode: FocusNode(skipTraversal: true),
                onPressed: () async {
                  appModel.zoomText = appModel.zoomText + appModel.zoomStep;
                  log(appModel.zoomText.toString());
                },
                icon: const Icon(Icons.text_increase),
                tooltip: 'Agrandir la taille du texte'),
            IconButton(
                onPressed: () async {
                  appModel.products = [];
                  appModel.suppliers = [];
                },
                icon: const Icon(Icons.refresh)),
            IconButton(
                focusNode: FocusNode(skipTraversal: true),
                onPressed: () async {
                  receptionModel.cleanForm();
                },
                icon: const Icon(Icons.clear),
                tooltip: 'Effacer le formulaire')
          ],
          title: Text(title),
        ),
        body: Container(padding: const EdgeInsets.all(12.0), child: w));
  }
}
