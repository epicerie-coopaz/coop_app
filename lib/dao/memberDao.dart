import 'dart:convert';

import 'package:coopaz_app/dao/data_access.dart';
import 'package:coopaz_app/logger.dart';
import 'package:coopaz_app/podo/member.dart';
import 'package:http/http.dart' as http;

class MemberDao extends GoogleSheetDao {
  MemberDao(
      {required super.googleSheetUrlApi,
      required super.spreadSheetId,
      required super.authManager});

  Future<List<Member>> getMembers() async {
    final response = await http.get(
        Uri.parse(
            "$googleSheetUrlApi/$spreadSheetId/values/'ImportMembres'!A:D?majorDimension=ROWS&prettyPrint=false"),
        headers: {
          'Authorization': 'Bearer ${await authManager.getAccessToken()}',
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
