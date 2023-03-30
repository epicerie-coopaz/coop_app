import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/ui/screens/cash_register/panel_cart_list.dart';
import 'package:coopaz_app/ui/screens/cash_register/panel_validation.dart';
import 'package:flutter/material.dart';

class CashRegisterTab extends StatefulWidget {
  CashRegisterTab({super.key, required this.tab, required this.orderDao});

  final int tab;
  final OrderDao orderDao;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  State<CashRegisterTab> createState() {
    return _CashRegisterTab();
  }
}

class _CashRegisterTab extends State<CashRegisterTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: widget._formKey,
          child: Row(children: [
            Expanded(
                flex: 5,
                child: CartList(
                  formKey: widget._formKey,
                  tab: widget.tab,
                )),
            const VerticalDivider(),
            Expanded(
                flex: 1,
                child: ValidationPanel(
                  tab: widget.tab,
                  orderDao: widget.orderDao,
                  formKey: widget._formKey,
                ))
          ]),
        ));
  }
}
