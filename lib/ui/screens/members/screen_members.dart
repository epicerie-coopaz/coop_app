import 'package:coopaz_app/dao/data_access.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/ui/common_widgets/loading_widget.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key, required this.memberDao});

  final GoogleSheetDao<Member> memberDao;

  @override
  State<StatefulWidget> createState() {
    return _MembersScreen();
  }
}

class _MembersScreen extends State<MembersScreen> {
  final String title = 'Adhérents';

  Map<String, int> toggleSorts = {
    "name": 1,
    "email": 1,
    "phone": 1,
  };
  int Function(Member, Member) memberCompare =
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());

  @override
  Widget build(BuildContext context) {
    log('Build screen $title');

    return Consumer<AppModel>(builder: (context, model, child) {
      Widget w;
      if (model.members.isNotEmpty) {
        w = _membersList(context, model);
      } else {
        widget.memberDao.get().then((m) => model.members = m);
        w = const Loading(text: 'Chargement de la liste des membres...');
      }
      return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () async {
                    model.members = [];
                  },
                  icon: const Icon(Icons.refresh))
            ],
            title: Text(title),
          ),
          body: Container(padding: const EdgeInsets.all(12.0), child: w));
    });
  }

  Widget _membersList(BuildContext context, AppModel model) {
    var styleHeaders = Theme.of(context)
        .primaryTextTheme
        .titleLarge
        ?.apply(color: Theme.of(context).colorScheme.primary);
    var styleBody = Theme.of(context).textTheme.bodyMedium;

    List<Member> membersSorted = model.members.toList();
    membersSorted.sort(memberCompare);

    return Column(
      children: [
        Expanded(
            flex: 0,
            child: Row(children: [
              Expanded(
                  flex: 2,
                  child: TextButton(
                    child: Text('Nom', style: styleHeaders),
                    onPressed: () {
                      int sortCoef = getSortCoef('name', toggleSorts);
                      setState(() {
                        memberCompare = (a, b) =>
                            a.name
                                .toLowerCase()
                                .compareTo(b.name.toLowerCase()) *
                            sortCoef;
                        toggleSorts = resetCoef('name', toggleSorts);
                      });
                    },
                  )),
              Expanded(
                  flex: 3,
                  child: TextButton(
                    child: Text('Email', style: styleHeaders),
                    onPressed: () {
                      int sortCoef = getSortCoef('email', toggleSorts);
                      setState(() {
                        memberCompare = (a, b) =>
                            a.email
                                .toLowerCase()
                                .compareTo(b.email.toLowerCase()) *
                            sortCoef;
                        toggleSorts = resetCoef('email', toggleSorts);
                      });
                    },
                  )),
              Expanded(
                  flex: 1,
                  child: TextButton(
                    child: Text('Téléphone', style: styleHeaders),
                    onPressed: () {
                      int sortCoef = getSortCoef('phone', toggleSorts);
                      setState(() {
                        memberCompare = (a, b) =>
                            a.phone
                                .toLowerCase()
                                .compareTo(b.phone.toLowerCase()) *
                            sortCoef;
                        toggleSorts = resetCoef('phone', toggleSorts);
                      });
                    },
                  )),
            ])),
        const Divider(
          thickness: 2,
        ),
        Expanded(
            flex: 1,
            child: ListView(
              addAutomaticKeepAlives: false,
              children: membersSorted.map((m) {
                return Column(children: [
                  Row(
                    children: [
                      Expanded(flex: 2, child: Text(m.name, style: styleBody)),
                      Expanded(flex: 3, child: Text(m.email, style: styleBody)),
                      Expanded(flex: 1, child: Text(m.phone, style: styleBody)),
                    ],
                  ),
                  const Divider()
                ]);
              }).toList(),
            ))
      ],
    );
  }
}
