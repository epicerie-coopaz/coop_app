import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/ui/common_widgets/widget_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberList extends StatelessWidget {
  MemberList({super.key});

  final Map<String, ColumnDef<Member>> columnsDef = {
    "name": ColumnDef(
        flex: 1,
        name: 'Nom',
        sort: (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        value: (a) => a.name),
    "email": ColumnDef(
        flex: 1,
        name: 'Email',
        sort: (a, b) => a.email.toLowerCase().compareTo(b.email.toLowerCase()),
        value: (a) => a.email),
    "phone": ColumnDef(
        flex: 1,
        name: 'Tel.',
        sort: (a, b) => a.phone.toLowerCase().compareTo(b.phone.toLowerCase()),
        value: (a) => a.phone),
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, model, child) {
      return WidgetList<Member>(
        columns: columnsDef,
        defaultSort: columnsDef["name"]!.sort,
        itemList: model.members.toList(),
      );
    });
  }
}
