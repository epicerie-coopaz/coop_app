import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/ui/screens/cash_register/panel_cart_list.dart';
import 'package:coopaz_app/ui/screens/cash_register/panel_validation.dart';
import 'package:flutter/material.dart';

class CashRegisterTab extends StatelessWidget {
  CashRegisterTab({super.key, required this.orderDao});

  final OrderDao orderDao;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String title = 'Caisse';

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Row(children: [
            Expanded(
                flex: 5,
                child: CartList(
                  formKey: _formKey,
                )),
            const VerticalDivider(),
            Expanded(
                flex: 1,
                child: ValidationPanel(
                  orderDao: orderDao,
                  formKey: _formKey,
                ))
          ]),
        ));
  }
}
