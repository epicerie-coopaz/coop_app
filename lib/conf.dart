import 'dart:convert';
import 'dart:io';

class Conf {
  late String clientId;
  late String clientSecret;
  late String redirectUri;
  late String projectId;
  late String spreadSheetId;
  late String appsScriptId;
  late Urls urls;

  Conf({paramsFilePath = './secrets/params.json'}) {
    String confFile = File(paramsFilePath).readAsStringSync();

    var confJson = jsonDecode(confFile);

    clientId = confJson['client_id'];
    projectId = confJson['project_id'];
    clientSecret = confJson['client_secret'];
    spreadSheetId = confJson['spread_sheet_id'];
    appsScriptId = confJson['apps_script_id'];
    urls = Urls(
      authUri: confJson['urls']['auth_uri'],
      tokenUri: confJson['urls']['token_uri'],
      googleSheetsApi: confJson['urls']['google_sheets_api'],
      googleAppsScriptApi: confJson['urls']['google_apps_script_api'],
      redirectUri: confJson['urls']['redirect_uri'],
      authProviderX509CertUrl: confJson['urls']['auth_provider_x509_cert_url'],
    );
  }
}

class Urls {
  String authUri;
  String tokenUri;
  String googleSheetsApi;
  String googleAppsScriptApi;
  String redirectUri;
  String authProviderX509CertUrl;

  Urls({
    required this.authUri,
    required this.tokenUri,
    required this.googleSheetsApi,
    required this.googleAppsScriptApi,
    required this.redirectUri,
    required this.authProviderX509CertUrl,
  });
}
