import 'package:coopaz_app/dao/member_dao.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/ui/common_widgets/loading_widget.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key, required this.memberDao});

  final MemberDao memberDao;

  @override
  State<StatefulWidget> createState() {
    return _MembersScreen();
  }
}

class _MembersScreen extends State<MembersScreen> {
  final String title = 'Adhérents';

  int toggleSort = 1;

  @override
  Widget build(BuildContext context) {
    log('Build screen $title');

    return Consumer<AppModel>(builder: (context, model, child) {
      Widget w;
      if (model.members.isNotEmpty) {
        w = _membersList(context, model);
      } else {
        widget.memberDao.getMembers().then((m) => model.members = m);
        w = const Loading(text: 'Chargement de la liste des membres...');
      }
      return Scaffold(
          appBar: AppBar(
            title: Row(children: [
              Text(title),
              const Spacer(),
              IconButton(
                  onPressed: () async {
                    model.members = [];
                  },
                  icon: const Icon(Icons.refresh))
            ]),
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

    List<Member> membersSorted = model.memberSorted();

    return Column(
      children: [
        Expanded(
            flex: 0,
            child: Row(children: [
              Expanded(
                  flex: 2,
                  child: Row(children: [
                    Text('Nom', style: styleHeaders),
                    IconButton(
                        onPressed: () {
                          model.setMemberSort((a, b) =>
                              a.name
                                  .toLowerCase()
                                  .compareTo(b.name.toLowerCase()) *
                              toggleSort);
                          setState(() {
                            toggleSort = toggleSort * -1;
                          });
                        },
                        icon: const Icon(Icons.sort_by_alpha))
                  ])),
              Expanded(
                  flex: 3,
                  child: Row(children: [
                    Text('Email', style: styleHeaders),
                    IconButton(
                        onPressed: () {
                          model.setMemberSort((a, b) =>
                              a.email
                                  .toLowerCase()
                                  .compareTo(b.email.toLowerCase()) *
                              toggleSort);

                          setState(() {
                            toggleSort = toggleSort * -1;
                          });
                        },
                        icon: const Icon(Icons.sort_by_alpha))
                  ])),
              Expanded(
                  flex: 1,
                  child: Row(children: [
                    Text('Téléphone', style: styleHeaders),
                    IconButton(
                        onPressed: () {
                          model.setMemberSort((a, b) =>
                              a.phone
                                  .toLowerCase()
                                  .compareTo(b.phone.toLowerCase()) *
                              toggleSort);
                          setState(() {
                            toggleSort = toggleSort * -1;
                          });
                        },
                        icon: const Icon(Icons.sort_by_alpha))
                  ])),
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
