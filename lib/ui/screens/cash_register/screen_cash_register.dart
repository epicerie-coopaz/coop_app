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

    CashRegisterModel cashRegisterModel =
        context.watch<CashRegisterModel>();

    List<Widget> tabs;
    if (appModel.products.isNotEmpty && appModel.members.isNotEmpty) {
      tabs =  [for (var i = 0; i <= cashRegisterModel.cashRegisterTabs; i++) i]
          .asMap()
          .map((key, _) => MapEntry(
                key,
                CashRegisterTab(orderDao: orderDao, tabIndex: key),
              ))
          .values
          .toList();
    } else {
      productDao.get().then((p) => appModel.products = p);
      memberDao.get().then((m) => appModel.members = m);
      tabs = const [
        Loading(text: 'Chargement de la liste des produits et adhérents...')
      ];
    }

    return DefaultTabController(
        length: cashRegisterModel.cashRegisterTabs,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [for (var i = 0; i <= cashRegisterModel.cashRegisterTabs; i++) i]
                  .asMap()
                  .map((key, value) => MapEntry(
                        key,
                        Tab(
                            child: Row(children: [
                          Text(
                            "Facture ${key + 1}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          IconButton(
                              focusNode: FocusNode(skipTraversal: true),
                              onPressed: () async {
                                cashRegisterModel.deleteTab(key);
                              },
                              icon: const Icon(
                                  Icons.remove_shopping_cart_outlined),
                              tooltip: 'Supprimer facture')
                        ])),
                      ))
                  .values
                  .toList(),
            ),
            actions: [
              IconButton(
                  focusNode: FocusNode(skipTraversal: true),
                  onPressed: () async {
                    cashRegisterModel.addTab();
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
                  tooltip: 'Recharger listes produits et adhérents'),
            ],
            title: Text(title),
          ),
          body: TabBarView(
            children: tabs,
          ),
        ));
  }
}
