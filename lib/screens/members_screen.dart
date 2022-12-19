import 'dart:convert';

import 'package:coopaz_app/conf.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:coopaz_app/podo/utils.dart';
import 'package:coopaz_app/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MembersScreen extends StatefulWidget {
  const MembersScreen(
      {super.key, required this.conf, required this.authManager});

  final AuthManager authManager;
  final Conf conf;

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
    futureMembers = fetchMembers();
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

  Future<List<Member>> fetchMembers() async {
    final response = await http.get(
        Uri.parse(
            "${widget.conf.urls.googleSheetsApi}/${widget.conf.spreadSheetId}/values/'ImportMembres'!A:D?majorDimension=ROWS&prettyPrint=false"),
        headers: {
          'Authorization':
              'Bearer ${await widget.authManager.getAccessToken()}',
          'Accept': 'application/json',
        });

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      List<List<String>> values = List<dynamic>.from(body['values'])
          .map((e) => List<String>.from(e))
          .toList();
      var members = values.where((element) {
        var isOk = element.length >= 4 && element[0].trim() != '';
        if (!isOk) {
          log('Bad line: $element');
        }
        return isOk;
      }).map((l) {
        var member = Member(
            name: l[0].trim(),
            email: l[1].trim(),
            phone: l[2].trim(),
            score: double.tryParse(l[3].trim()) ?? double.nan);

        return member;
      }).toList();

      return members;
    } else {
      log('Failed to load products: [${response.statusCode}] ${response.body}');
      throw Exception(
          'Failed to load products: [${response.statusCode}] ${response.body}');
    }
  }
}
