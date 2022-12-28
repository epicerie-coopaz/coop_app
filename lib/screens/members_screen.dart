import 'package:coopaz_app/dao/memberDao.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/podo/utils.dart';
import 'package:flutter/material.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key, required this.memberDao});

  final MemberDao memberDao;

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final String title = 'Adhérents';

  late Future<List<Member>> futureMembers;

  @override
  void initState() {
    log('Init screen $title...');
    super.initState();
    futureMembers = widget.memberDao.getMembers();
    log('Init screen $title finish');
  }

  @override
  Widget build(BuildContext context) {
    log('Build screen $title');

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: FutureBuilder<List<Member>>(
          future: futureMembers,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var styleHeaders = Theme.of(context)
                  .primaryTextTheme
                  .titleMedium
                  ?.apply(color: Colors.blue);
              var styleBody = Theme.of(context)
                  .primaryTextTheme
                  .bodyMedium
                  ?.apply(color: Colors.black);
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
                        children: snapshot.data!.map((p) {
                          return Column(children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Text(p.name, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.email, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.phone, style: styleBody)),
                                Expanded(
                                    flex: 1,
                                    child: Text(p.score.toString(),
                                        style: styleBody)),
                              ],
                            ),
                            const Divider()
                          ]);
                        }).toList(),
                      ))
                ],
              ); //Text(snapshot.data!.title);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ));
  }
}
