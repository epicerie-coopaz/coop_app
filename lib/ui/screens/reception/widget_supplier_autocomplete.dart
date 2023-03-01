import 'package:coopaz_app/podo/supplier.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/state/reception.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class SupplierAutocomplete extends StatelessWidget {
  const SupplierAutocomplete({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    AppModel appModel = context.watch<AppModel>();
    ReceptionModel receptionModel = context.watch<ReceptionModel>();
    double mediumText = 14 * appModel.zoomText;

    return Autocomplete<Supplier>(
      initialValue:
          TextEditingValue(text: receptionModel.selectedSupplier?.name ?? ''),
      key: ValueKey(receptionModel.selectedSupplier),
      displayStringForOption: (Supplier s) => s.name,
      optionsBuilder: (TextEditingValue textEditingValue) {
        List<Supplier> suppliers = appModel.suppliers.where((Supplier s) {
          List<String> matchList =
              textEditingValue.text.toLowerCase().split(' ');
          bool matchAll = true;
          for (String match in matchList) {
            if (!s.toString().toLowerCase().contains(match)) {
              matchAll = false;
              break;
            }
          }

          return matchAll;
        }).toList();
        suppliers.sort(
          (a, b) => a.name.compareTo(b.name),
        );
        return suppliers;
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted) {
        return TextFormField(
          decoration: const InputDecoration(
            hintText: 'Fournisseur',
          ),
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          style: TextStyle(fontSize: mediumText),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Material(
          elevation: 4.0,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final Supplier option = options.elementAt(index);
              return InkWell(
                onTap: () {
                  onSelected(option);
                },
                child: Builder(builder: (BuildContext context) {
                  final bool highlight =
                      AutocompleteHighlightedOption.of(context) == index;
                  if (highlight) {
                    SchedulerBinding.instance
                        .addPostFrameCallback((Duration timeStamp) {
                      Scrollable.ensureVisible(context, alignment: 0.5);
                    });
                  }
                  var styleBody = Theme.of(context).textTheme.bodyMedium;
                  return Container(
                    color: highlight ? Theme.of(context).focusColor : null,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text(option.name, style: styleBody)),
                        Expanded(
                            flex: 1,
                            child: Text(option.contactName, style: styleBody)),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        );
      },
      onSelected: (s) {
        receptionModel.selectedSupplier = s;
        receptionModel.selectedProduct = null;
      },
    );
  }
}
