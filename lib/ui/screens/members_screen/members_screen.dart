import 'package:coopaz_app/dao/member_dao.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/utils.dart';
import 'package:coopaz_app/ui/common_widgets/loading_widget.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key, required this.memberDao});

  final MemberDao memberDao;

  final String title = 'Adhérents';

  @override
  Widget build(BuildContext context) {
    log('Build screen $title');

    return Consumer<AppModel>(builder: (context, model, child) {
      Widget w;
      if (model.members.isNotEmpty) {
        w = _membersList(context, model);
      } else {
        memberDao.getMembers().then((m) => model.members = m);
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

    return Column(
      children: [
        Expanded(
            flex: 0,
            child: Row(
                children: [
              Pair('Nom', 1),
              Pair('Email', 1),
              Pair('Téléphone', 1),
              Pair('Score', 1),
            ]
                    .map(
                      (e) => Expanded(
                        flex: e.b,
                        child: Text(
                          e.a,
                          style: styleHeaders,
                        ),
                      ),
                    )
                    .toList())),
        const Divider(
          thickness: 2,
        ),
        Expanded(
            flex: 1,
            child: ListView(
              addAutomaticKeepAlives: false,
              children: model.members.map((m) {
                return Column(children: [
                  Row(
                    children: [
                      Expanded(flex: 1, child: Text(m.name, style: styleBody)),
                      Expanded(flex: 1, child: Text(m.email, style: styleBody)),
                      Expanded(flex: 1, child: Text(m.phone, style: styleBody)),
                      Expanded(
                          flex: 1,
                          child: Text(m.score.toString(), style: styleBody)),
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
