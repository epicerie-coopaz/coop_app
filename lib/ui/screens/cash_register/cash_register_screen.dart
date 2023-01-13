import 'package:coopaz_app/dao/member_dao.dart';
import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/dao/product_dao.dart';
import 'package:coopaz_app/ui/screens/cash_register/product_list.dart';
import 'package:coopaz_app/ui/screens/cash_register/validation_panel.dart';
import 'package:coopaz_app/ui/common_widgets/loading_widget.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:flutter/material.dart';
import 'package:coopaz_app/logger.dart';
import 'package:provider/provider.dart';

class CashRegisterScreen extends StatelessWidget {
  CashRegisterScreen(
      {super.key,
      required this.orderDao,
      required this.memberDao,
      required this.productDao});

  final OrderDao orderDao;
  final MemberDao memberDao;
  final ProductDao productDao;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String title = 'Caisse';

  @override
  Widget build(BuildContext context) {
    log('build screen $title');

    AppModel appModel = context.watch<AppModel>();

    Widget cartList;
    if (appModel.products.isNotEmpty) {
      cartList = ProductList(
        formKey: _formKey,
      );
    } else {
      productDao.getProducts().then((p) => appModel.products = p);
      cartList = const Loading(text: 'Chargement de la liste des produits...');
    }

    Widget validationPanel;
    if (appModel.members.isNotEmpty) {
      validationPanel = ValidationPanel(
        orderDao: orderDao,
        formKey: _formKey,
      );
    } else {
      memberDao.getMembers().then((m) => appModel.members = m);
      validationPanel =
          const Loading(text: 'Chargement de la liste des membres...');
    }

    return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Text(title),
            const Spacer(),
            IconButton(
                onPressed: () async {
                  appModel.products = [];
                  appModel.members = [];
                },
                icon: const Icon(Icons.refresh))
          ]),
        ),
        body: Container(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Row(children: [
                Expanded(flex: 3, child: cartList),
                const VerticalDivider(),
                Expanded(flex: 1, child: validationPanel)
              ]),
            )));
  }
}
