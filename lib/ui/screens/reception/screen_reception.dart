import 'package:coopaz_app/dao/product_dao.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReceptionScreen extends StatefulWidget {
  const ReceptionScreen({super.key, required this.productDao});

  final ProductDao productDao;

  @override
  State<StatefulWidget> createState() {
    return _ReceptionScreen();
  }
}

class _ReceptionScreen extends State<ReceptionScreen> {
  final String title = 'Réception';


  @override
  Widget build(BuildContext context) {
    log('Build screen $title');

    return Consumer<AppModel>(builder: (context, model, child) {

      return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () async {
                    model.members = [];
                  },
                  icon: const Icon(Icons.refresh))
            ],
            title: Text(title),
          ),
          body: const Text("Reception"));
    });
  }

}
