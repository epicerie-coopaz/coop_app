import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ColumnDef<T> {
  final int flex;
  final String name;
  final int Function(T, T) sort;
  final String Function(T) value;

  const ColumnDef({required this.name, required this.flex, required this.sort, required this.value});
}

class WidgetList<T> extends StatefulWidget {
  const WidgetList(
      {super.key,
      required this.itemList,
      required this.columns,
      required this.defaultSort});

  final List<T> itemList;
  final Map<String, ColumnDef<T>> columns;
  final int Function(T, T) defaultSort;

  @override
  State<StatefulWidget> createState() {
    return _WidgetList<T>();
  }
}

class _WidgetList<T> extends State<WidgetList<T>> {
  late Map<String, int> _toggleSorts;
  late int Function(T, T) _activeSort;
  late List<T> _listSorted;

  @override
  initState() {
    super.initState();

    _toggleSorts = widget.columns.map((key, value) => MapEntry(key, 1));
    _activeSort = widget.defaultSort;
    _listSorted = widget.itemList;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, model, child) {
      var styleHeaders = Theme.of(context)
          .primaryTextTheme
          .titleLarge
          ?.apply(color: Theme.of(context).colorScheme.primary);
      var styleBody = Theme.of(context).textTheme.bodyMedium;

      _listSorted.sort(_activeSort);

      return Column(
        children: [
          Expanded(
              flex: 0,
              child: Row(
                  children: widget.columns.entries
                      .map((e) => Expanded(
                          flex: e.value.flex,
                          child: TextButton(
                            child: Text(e.value.name, style: styleHeaders),
                            onPressed: () {
                              int sortCoef = getSortCoef(e.key, _toggleSorts);
                              setState(() {
                                _activeSort =
                                    (a, b) => e.value.sort(a, b) * sortCoef;
                                _toggleSorts = resetCoef(e.key, _toggleSorts);
                              });
                            },
                          )))
                      .toList())),
          const Divider(
            thickness: 2,
          ),
          Expanded(
              flex: 1,
              child: ListView(
                addAutomaticKeepAlives: false,
                children: _listSorted.map((t) {
                  return Column(children: [
                    Row(
                        children: widget.columns.entries
                            .map((e) => Expanded(
                            flex: e.value.flex,
                            child: Text(e.value.value(t), style: styleBody)),)
                            .toList()),
                    const Divider()
                  ]);
                }).toList(),
              ))
        ],
      );
    });
  }
}
