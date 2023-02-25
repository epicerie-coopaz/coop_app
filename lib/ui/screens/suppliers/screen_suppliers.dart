import 'package:coopaz_app/dao/data_access.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/supplier.dart';
import 'package:coopaz_app/ui/common_widgets/loading_widget.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widget_supplier_list.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key, required this.supplierDao});

  final GoogleSheetDao<Supplier> supplierDao;

  final String title = 'Fournisseurs';

  @override
  Widget build(BuildContext context) {
    log('Build screen $title');

    return Consumer<AppModel>(builder: (context, model, child) {
      Widget w;
      if (model.suppliers.isNotEmpty) {
        w = const SupplierList();
      } else {
        supplierDao.get().then((s) => model.suppliers = s);
        w = const Loading(text: 'Chargement de la liste des fournisseurs...');
      }
      return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () async {
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
