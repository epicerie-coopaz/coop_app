import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/state/model.dart';
import 'package:flutter/material.dart';
import 'package:coopaz_app/logger.dart';
import 'package:provider/provider.dart';

class ValidationPanel extends StatefulWidget {
  const ValidationPanel(
      {super.key, required this.orderDao, required this.formKey});

  final GlobalKey<FormState> formKey;
  final OrderDao orderDao;

  @override
  State<ValidationPanel> createState() => _ValidationPanelState();
}

class _ValidationPanelState extends State<ValidationPanel> {
  final String title = 'Caisse';

  static const double cardFeeRate = 0.00553;
  static const List<String> paymentMethodList = <String>[
    'CB',
    'Cheque',
    'Virement'
  ];
  //Form data
  String paymentmethodSelected = paymentMethodList.first;

  Member? selectedMember;

  @override
  Widget build(BuildContext context) {
    log('build ValidationPanel');

    return Consumer<AppModel>(builder: (context, model, child) {
      double subtotal = model.cart
          .map((e) =>
              (double.tryParse(e.qty ?? '0') ?? 0.0) *
              (double.tryParse(e.unitPrice ?? '0') ?? 0.0))
          .fold(0.0, (prev, e) => prev + e);

      double cardFee = 0.0;
      if (paymentmethodSelected == 'CB') {
        cardFee = subtotal * cardFeeRate;
      }

      double total = subtotal + cardFee;

      return Column(children: [
        Row(children: [
          const Expanded(
              flex: 1,
              child: Text(
                'Adhérent :',
              )),
          Expanded(
              flex: 2,
              child: Autocomplete<Member>(
                displayStringForOption: (Member m) => '${m.name} : ${m.email}',
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text == '') {
                    return const Iterable<Member>.empty();
                  }
                  return model.members.where((Member m) {
                    return m
                        .toString()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (m) {
                  setState(() {
                    selectedMember = m;
                  });
                },
              )),
        ]),
        Row(children: [
          const Expanded(
              flex: 1,
              child: Align(
                  alignment: Alignment.topLeft, child: Text('Paiement : '))),
          Expanded(
              flex: 2,
              child: DropdownButton<String>(
                value: paymentmethodSelected,
                elevation: 16,
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    paymentmethodSelected = value!;
                  });
                },
                items: paymentMethodList
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ))
        ]),
        //Todo: add a text box to enter cheque number
        //if(paymentmethodSelected == 'Cheque') {widgets...}
        Row(children: [
          const Expanded(
              flex: 1,
              child: Align(
                  alignment: Alignment.topLeft, child: Text('Sous total : '))),
          Expanded(
              flex: 2,
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('${subtotal.toStringAsFixed(2)}€')))
        ]),
        Row(children: [
          const Expanded(
              flex: 1,
              child:
                  Align(alignment: Alignment.topLeft, child: Text('Total : '))),
          Expanded(
              flex: 2,
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('${total.toStringAsFixed(2)}€')))
        ]),
        Center(
            child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
          onPressed: () {
            if (_validateAll()) {
              log('Send form !!!');
              _sendForm(model);
            } else {
              log('Form invalid');
            }
          },
          child: const Text('Valider'),
        )),
      ]);
    });
  }

  bool _validateAll() {
    log(widget.formKey.currentState.toString());
    if (widget.formKey.currentState!.validate()) {
      return true;
    }
    return false;
  }

  _sendForm(AppModel model) async {
    // send data to macro
    await widget.orderDao
        .createOrder(selectedMember?.email ?? '', model.cart, "");
    // reset form
    widget.formKey.currentState?.reset();

    model.cleanCart();
  }
}
