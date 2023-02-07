import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/podo/payment_method.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/state/cash_register.dart';
import 'package:coopaz_app/ui/common_widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:coopaz_app/logger.dart';
import 'package:provider/provider.dart';

class ValidationPanel extends StatelessWidget {
  const ValidationPanel(
      {super.key, required this.orderDao, required this.formKey});

  final GlobalKey<FormState> formKey;
  final OrderDao orderDao;

  final String title = 'Caisse';

  static const double cardFeeRate = 0.00553;

  @override
  Widget build(BuildContext context) {
    log('build ValidationPanel');

    AppModel appModel = context.watch<AppModel>();
    CashRegisterModel cashRegisterModel = context.watch<CashRegisterModel>();

    double subtotal = context
        .watch<CashRegisterModel>()
        .cart
        .map((e) =>
            (double.tryParse(e.qty ?? '0') ?? 0.0) * (e.product?.price ?? 0.0))
        .fold(0.0, (prev, e) => prev + e);

    double cardFee = 0.0;
    if (cashRegisterModel.selectedPaymentMethod == PaymentMethod.card) {
      cardFee = subtotal * ValidationPanel.cardFeeRate;
    }

    double total = subtotal + cardFee;

    return Column(children: [
      Container(
          padding: const EdgeInsets.only(top: 8),
          alignment: Alignment.bottomLeft,
          child: Text('Adhérent :',
              textScaleFactor: appModel.textSize,
              style: const TextStyle(fontWeight: FontWeight.w600))),
      Container(
          alignment: Alignment.bottomLeft,
          child: !cashRegisterModel.isAwaitingSendFormResponse
              ? Autocomplete<Member>(
                  key: ValueKey(cashRegisterModel.selectedMember?.name ?? ''),
                  initialValue: TextEditingValue(
                      text: cashRegisterModel.selectedMember?.name ?? ''),
                  displayStringForOption: (Member m) => m.name,
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text == '') {
                      return const Iterable<Member>.empty();
                    }
                    return appModel.members.where((Member m) {
                      return m
                          .toString()
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextField(
                      decoration: const InputDecoration(
                        hintText: 'Nom adhérent',
                      ),
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      style: TextStyle(fontSize: 14 * appModel.textSize),
                    );
                  },
                  onSelected: (m) {
                    cashRegisterModel.selectedMember = m;
                  },
                )
              : Text(cashRegisterModel.selectedMember!.name)),
      Container(
          padding: const EdgeInsets.only(top: 25),
          alignment: Alignment.bottomLeft,
          child: Text('Paiement : ',style: TextStyle(fontSize: 11 * appModel.textSize))),
      Row(children: [
        Expanded(
            flex: 2,
            child: !cashRegisterModel.isAwaitingSendFormResponse
                ? DropdownButton<PaymentMethod>(
                    value: cashRegisterModel.selectedPaymentMethod,
                    elevation: 16,
                    onChanged: (PaymentMethod? value) {
                      // This is called when the user selects an item.
                      cashRegisterModel.selectedPaymentMethod =
                          value ?? PaymentMethod.card;
                    },
                    items: PaymentMethod.values
                        .map<DropdownMenuItem<PaymentMethod>>(
                            (PaymentMethod value) {
                      return DropdownMenuItem<PaymentMethod>(
                        value: value,
                        child: Text(value.asString,
                            style: TextStyle(fontSize: 11 * appModel.textSize)),
                      );
                    }).toList(),
                  )
                : Text(cashRegisterModel.selectedPaymentMethod.asString,
                    textScaleFactor: appModel.textSize))
      ]),
      if (cashRegisterModel.selectedPaymentMethod == PaymentMethod.cheque)
        TextFormField(
          controller: TextEditingController(
              text: cashRegisterModel.chequeOrTransferNumber)
            ..selection = TextSelection.collapsed(
                offset: (cashRegisterModel.chequeOrTransferNumber).length),
          decoration: const InputDecoration(
            hintText: 'N. chèque',
          ),
          onChanged: (String value) {
            cashRegisterModel.chequeOrTransferNumber = value;
          },
          textAlign: TextAlign.right,
        ),
      if (cashRegisterModel.selectedPaymentMethod == PaymentMethod.transfer)
        TextFormField(
          controller: TextEditingController(
              text: cashRegisterModel.chequeOrTransferNumber)
            ..selection = TextSelection.collapsed(
                offset: (cashRegisterModel.chequeOrTransferNumber).length),
          decoration: const InputDecoration(
            hintText: 'N. virement',
          ),
          onChanged: (String value) {
            cashRegisterModel.chequeOrTransferNumber = value;
          },
          textAlign: TextAlign.right,
        ),
      Container(
        padding: const EdgeInsets.only(top: 25),
        child: Row(children: [
          Expanded(
              flex: 1,
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('Sous total : ',
                      style: TextStyle(fontSize: 11 * appModel.textSize)))),
          Expanded(
              flex: 1,
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('${subtotal.toStringAsFixed(2)}€',
                      style: TextStyle(fontSize: 11 * appModel.textSize))))
        ]),
      ),
      Container(
        padding: const EdgeInsets.only(top: 5),
        child: Row(children: [
          Expanded(
              flex: 1,
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('Total : ',
                      textScaleFactor: appModel.textSize,
                      style: const TextStyle(fontWeight: FontWeight.bold)))),
          Expanded(
              flex: 1,
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('${total.toStringAsFixed(2)}€',
                      textScaleFactor: appModel.textSize,
                      style: const TextStyle(fontWeight: FontWeight.bold))))
        ]),
      ),
      if (cashRegisterModel.isAwaitingSendFormResponse == false)
        Center(
            child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
              minimumSize: const Size(100, 50),
            ),
            onPressed: () {
              if (_validateAll()) {
                log('Send form !!!');
                _sendForm(cashRegisterModel);
              } else {
                log('Form invalid');
              }
            },
            child: Text('Valider', textScaleFactor: appModel.textSize),
          ),
        ))
      else
        const Loading(text: "En attente du traitement de la facture..."),
    ]);
  }

  bool _validateAll() {
    log(formKey.currentState.toString());
    if (formKey.currentState!.validate()) {
      return true;
    }
    return false;
  }

  _sendForm(CashRegisterModel model) async {
    model.isAwaitingSendFormResponse = true;

    // send data to macro
    String chequeOrTransferNumber = '';

    if (model.selectedPaymentMethod != PaymentMethod.card) {
      chequeOrTransferNumber = model.chequeOrTransferNumber;
    }

    await orderDao.createOrder(model.selectedMember?.email ?? '', model.cart,
        model.selectedPaymentMethod, chequeOrTransferNumber);
    // reset form
    formKey.currentState?.reset();

    model.cleanCart();
    model.isAwaitingSendFormResponse = false;
  }
}
