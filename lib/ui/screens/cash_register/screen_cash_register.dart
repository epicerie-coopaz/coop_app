import 'package:coopaz_app/dao/data_access.dart';
import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/state/cash_register.dart';
import 'package:coopaz_app/ui/screens/cash_register/panel_cart_list.dart';
import 'package:coopaz_app/ui/screens/cash_register/panel_validation.dart';
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
  final GoogleSheetDao<Member> memberDao;
  final GoogleSheetDao<Product> productDao;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String title = 'Caisse';

  @override
  Widget build(BuildContext context) {
    log('build screen $title');

    AppModel appModel = context.watch<AppModel>();

    CashRegisterModel cashRegisterModel = context.watch<CashRegisterModel>();

    Widget cartList;
    if (appModel.products.isNotEmpty) {
      cartList = CartList(
        formKey: _formKey,
      );
    } else {
      productDao.get().then((p) => appModel.products = p);
      cartList = const Loading(text: 'Chargement de la liste des produits...');
    }

    Widget validationPanel;
    if (appModel.members.isNotEmpty) {
      validationPanel = ValidationPanel(
        orderDao: orderDao,
        formKey: _formKey,
      );
    } else {
      memberDao.get().then((m) => appModel.members = m);
      validationPanel =
          const Loading(text: 'Chargement de la liste des membres...');
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
                focusNode: FocusNode(skipTraversal: true),
                onPressed: () async {
                  appModel.products = [];
                  appModel.members = [];
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Recharger listes produits et adhérents'),
            IconButton(
                focusNode: FocusNode(skipTraversal: true),
                onPressed: () async {
                  cashRegisterModel.cleanCart();
                },
                icon: const Icon(Icons.clear),
                tooltip: 'Effacer le formulaire')
          ],
          title: Text(title),
        ),
        body: Container(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Row(children: [
                Expanded(flex: 5, child: cartList),
                const VerticalDivider(),
                Expanded(flex: 1, child: validationPanel)
              ]),
            )));
  }
}
