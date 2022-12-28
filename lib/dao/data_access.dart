import '../auth.dart';

class GoogleSheetDao {
  final String googleSheetUrlApi;
  final String spreadSheetId;
  final AuthManager authManager;

  const GoogleSheetDao(
      {required this.googleSheetUrlApi,
      required this.spreadSheetId,
      required this.authManager});
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
