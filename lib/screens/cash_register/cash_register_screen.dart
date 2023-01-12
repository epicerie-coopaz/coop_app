import 'package:coopaz_app/dao/member_dao.dart';
import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/dao/product_dao.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/screens/cash_register/product_list.dart';
import 'package:coopaz_app/screens/cash_register/validation_panel.dart';
import 'package:coopaz_app/screens/loading_widget.dart';
import 'package:coopaz_app/state/model.dart';
import 'package:flutter/material.dart';
import 'package:coopaz_app/logger.dart';
import 'package:provider/provider.dart';

class CashRegisterScreen extends StatefulWidget {
  const CashRegisterScreen(
      {super.key,
      required this.orderDao,
      required this.memberDao,
      required this.productDao});

  final OrderDao orderDao;
  final MemberDao memberDao;
  final ProductDao productDao;

  @override
  State<CashRegisterScreen> createState() => _CashRegisterScreenState();
}

class _CashRegisterScreenState extends State<CashRegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String title = 'Caisse';

  late Future<List<Member>> futureMembers;
  late Future<List<Product>> futureProducts;

  @override
  initState() {
    log('Init screen $title...');
    super.initState();
    log('Get members...');
    futureMembers = widget.memberDao.getMembers();
    log('Get products...');
    futureProducts = widget.productDao.getProducts();

    log('Init screen $title finish');
  }

  @override
  Widget build(BuildContext context) {
    log('build screen $title');

    return Consumer<AppModel>(builder: (context, model, child) {
      Widget cartList;
      if (model.products.isNotEmpty) {
        cartList = ProductList(
          formKey: _formKey,
        );
      } else {
        widget.productDao.getProducts().then((p) => model.products = p);
        cartList =
            const Loading(text: 'Chargement de la liste des produits...');
      }

      Widget validationPanel;
      if (model.products.isNotEmpty) {
        validationPanel = ValidationPanel(
          orderDao: widget.orderDao,
          formKey: _formKey,
        );
      } else {
        widget.memberDao.getMembers().then((m) => model.members = m);
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
                    model.products = [];
                    model.members = [];
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
    });
  }
}
