import 'dart:convert';
import 'dart:developer';

import 'package:coopaz_app/auth.dart';
import 'package:http/http.dart' as http;

class GoogleSheetDao<T> {
  final String googleSheetUrlApi;
  final String spreadSheetId;
  final AuthManager authManager;
  final String sheetName;
  final String range;
  final T Function(List<String>) mapping;
  final bool Function(List<String>) filter;

  const GoogleSheetDao({
    required this.googleSheetUrlApi,
    required this.spreadSheetId,
    required this.authManager,
    required this.sheetName,
    required this.range,
    required this.mapping,
    required this.filter,
  });

  Future<List<T>> get() async {
    final response = await http.get(
        Uri.parse(
            "$googleSheetUrlApi/$spreadSheetId/values/'$sheetName'$range?majorDimension=ROWS&prettyPrint=false"),
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
        var isOk = filter(element);
        if (!isOk) {
          log('Bad line: $element');
        }
        return isOk;
      }).map((l) {
        var o = mapping(l);
        return o;
      }).toList();

      return members;
    } else {
      log('Failed to load data: [${response.statusCode}] ${response.body}');
      throw Exception(
          'Failed to load data: [${response.statusCode}] ${response.body}');
    }
  }
}

class GoogleAppsScriptDao {
  final String googleAppsScriptUrlApi;
  final String appsScriptId;
  final AuthManager authManager;

  const GoogleAppsScriptDao(
      {required this.googleAppsScriptUrlApi,
      required this.appsScriptId,
      required this.authManager});
}
