import 'package:coopaz_app/dao/member_dao.dart';
import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/dao/product_dao.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/podo/product.dart';
import 'package:coopaz_app/screens/cash_register/product_list.dart';
import 'package:coopaz_app/screens/cash_register/validation_panel.dart';
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
      futureProducts.then((p) {
        model.products = p;
      });

      futureMembers.then((m) {
        model.members = m;
      });

      return Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: Container(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: _formKey,
                child: Row(children: [
                  Expanded(
                      flex: 3,
                      child: FutureBuilder<List<Product>>(
                          future: futureProducts,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Product>> snapshot) {
                            Widget w;
                            if (snapshot.hasData) {
                              //model.products = snapshot.data ?? [];
                              log('product loaded !');
                              w = ProductList(
                                formKey: _formKey,
                              );
                            } else if (snapshot.hasError) {
                              log('products loading in error...');
                              w = Column(children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 60,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text('Error: ${snapshot.error}'),
                                ),
                              ]);
                            } else {
                              log('product loading...');
                              w = Column(children: const [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Text(
                                      'Chargement de la liste des produits...'),
                                ),
                              ]);
                            }

                            return w;
                          })),
                  const VerticalDivider(),
                  Expanded(
                      flex: 1,
                      child: FutureBuilder<List<Member>>(
                          future: futureMembers,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Member>> snapshot) {
                            Widget w;
                            if (snapshot.hasData) {
                              log('members loaded !');
                              //model.members = snapshot.data ?? [];
                              w = ValidationPanel(
                                orderDao: widget.orderDao,
                                formKey: _formKey,
                              );
                            } else if (snapshot.hasError) {
                              log('members loading in error...');
                              w = Column(children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 60,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text('Error: ${snapshot.error}'),
                                ),
                              ]);
                            } else {
                              log('members loading...');
                              w = Column(children: const [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Text(
                                      'Chargement de la liste des membres...'),
                                ),
                              ]);
                            }

                            return w;
                          }))
                ]),
              )));
    });
  }
}
