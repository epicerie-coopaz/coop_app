import 'package:coopaz_app/dao/data_access.dart';
import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/state/cash_register.dart';
import 'package:coopaz_app/ui/common_widgets/loading_widget.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/ui/screens/cash_register/tab_cash_register.dart';
import 'package:flutter/material.dart';
import 'package:coopaz_app/logger.dart';
import 'package:provider/provider.dart';

class CashRegisterScreen extends StatelessWidget {
  const CashRegisterScreen(
      {super.key,
      required this.orderDao,
      required this.memberDao,
      required this.productDao});

  final OrderDao orderDao;
  final GoogleSheetDao<Member> memberDao;
  final GoogleSheetDao<Product> productDao;

  final String title = 'Caisse';

  @override
  Widget build(BuildContext context) {
    log('build screen $title');
    AppModel appModel = context.watch<AppModel>();
    CashRegisterTabModel cashRegisterTabModel =
        context.watch<CashRegisterTabModel>();

    Widget w;
    if (appModel.products.isNotEmpty && appModel.members.isNotEmpty) {
      w = TabBarView(
        children: cashRegisterTabModel.cashRegisterTabs.map((tabNumber) {
          return CashRegisterTab(
            orderDao: orderDao,
          );
        }).toList(),
      );
    } else {
      productDao.get().then((p) => appModel.products = p);
      memberDao.get().then((m) => appModel.members = m);
      w = const Loading(
          text: 'Chargement de la liste des produits et adhérents...');
    }

    List<Widget> tabs = cashRegisterTabModel.cashRegisterTabs
        .asMap()
        .map((key, value) => MapEntry(
              key,
              Tab(
                  child: Row(children: [
                Text(
                  "Facture $value",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textScaleFactor: appModel.zoomText,
                ),
                const Spacer(),
                IconButton(
                    focusNode: FocusNode(skipTraversal: true),
                    onPressed: () async {
                      cashRegisterTabModel.deleteTab(key);
                    },
                    icon: const Icon(Icons.delete),
                    tooltip: 'Supprimer facture')
              ])),
            ))
        .values
        .toList();

    return DefaultTabController(
        length: cashRegisterTabModel.cashRegisterTabs.length,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              bottom: TabBar(
                indicator: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Theme.of(context).colorScheme.surface,
                ),
                tabs: tabs,
              ),
              actions: [
                IconButton(
                    focusNode: FocusNode(skipTraversal: true),
                    onPressed: () async {
                      cashRegisterTabModel.addTab();
                    },
                    icon: const Icon(Icons.add_shopping_cart_outlined),
                    tooltip: 'Nouvelle facture'),
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
                    tooltip: 'Recharger listes produits et adhérents')
              ],
              title: Text(title),
            ),
            body: w));
  }
}
