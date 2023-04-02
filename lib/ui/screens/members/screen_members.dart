import 'package:coopaz_app/dao/data_access.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/ui/common_widgets/loading_widget.dart';
import 'package:coopaz_app/state/app_model.dart';
import 'package:coopaz_app/ui/screens/members/widget_member_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key, required this.memberDao});

  final GoogleSheetDao<Member> memberDao;

  final String title = 'Adhérents';

  @override
  Widget build(BuildContext context) {
    log('Build screen $title');

    return Consumer<AppModel>(builder: (context, model, child) {
      Widget w;
      if (model.members.isNotEmpty) {
        w = MemberList();
      } else {
        memberDao.get().then((m) => model.members = m);
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
}
