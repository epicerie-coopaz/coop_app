import 'dart:convert';
import 'dart:io';
import 'package:coopaz_app/conf.dart';
import 'package:coopaz_app/logger.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthManager {
  AuthManager({required this.conf});

  Conf conf;

  String? authCode;
  String? clientId;
  String? clientSecret;
  String? redirectUri;
  String responseType = 'code';
  String scope = 'https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/script.external_request https://www.googleapis.com/auth/script.send_mail https://www.googleapis.com/auth/gmail.readonly https://www.googleapis.com/auth/gmail.send';
  String? refreshToken;
  String? accessToken;
  DateTime? accessTokenValidUntil;

  Future init() async {
    clientId = conf.clientId;
    clientSecret = conf.clientSecret;
    redirectUri = conf.urls.redirectUri;
  }

  Future<String> getAccessToken() async {
    if (refreshToken == null) {
      await getRefreshToken();
    }
    // If the access token is not here of expire soon we request a new one
    if (accessToken == null ||
        (accessTokenValidUntil?.difference(DateTime.now()).inSeconds ?? 0) <
            10) {
      final response = await post(Uri.parse(conf.urls.tokenUri), headers: {
        "Accept": "application/json",
      }, body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken
      });

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to get access token: [${response.statusCode}] ${response.body}');
      }

      var body = jsonDecode(response.body);

      accessToken = body['access_token'];
      log('New access token received: $accessToken');
      accessTokenValidUntil =
          DateTime.now().add(Duration(seconds: body['expires_in']));
      log('New token valid until : $accessTokenValidUntil');
    }

    log('Token : $accessToken');
    log('Access token valid until: $accessTokenValidUntil');

    return accessToken ?? '';
  }

  Future getAuth() async {
    final url = await _getAuthUrl();
    log('Get auth url: $url');

    final uri = Uri.parse(url);
    await launchUrl(uri);

    var server = await HttpServer.bind(InternetAddress.anyIPv6, 8080);
    var requestFromGoogle = await server.first;

    authCode = requestFromGoogle.uri.queryParameters['code'];
    if (authCode != null) {
      requestFromGoogle.response
          .write('Auth ok! \n\nTu peux fermer cette fenêtre mon lapin. <3');
      log('New auth code received: $authCode');
    } else {
      requestFromGoogle.response
          .write('Auth ko... Pas de code d\'auth reçu... :(');
    }

    requestFromGoogle.response.close();
  }

  Future getRefreshToken() async {
    if (authCode == null) {
      await getAuth();
    }
    final response = await post(Uri.parse(conf.urls.tokenUri), headers: {
      "Accept": "application/json",
    }, body: {
      'code': authCode,
      'client_id': clientId,
      'client_secret': clientSecret,
      'redirect_uri': redirectUri,
      'grant_type': 'authorization_code'
    });

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get refresh token: [${response.statusCode}] ${response.body}');
    }
    var body = jsonDecode(response.body);

    accessToken = body['access_token'];

    refreshToken = body['refresh_token'];
    log('New refresh token received: $refreshToken');
    log('New access token received: $accessToken');
    accessTokenValidUntil =
        DateTime.now().add(Duration(seconds: body['expires_in']));
    log('New token valid until : $accessTokenValidUntil');
  }

  Future<String> _getAuthUrl() async {
    // String url = '$googleAuthUrl?scope=$scope&response_type=$responseType&redirect_uri=$redirectUri&client_id=$clientId&code_challenge=$codeChallenge&code_challenge_method=$codeChallengeMethod';
    String url =
        '${conf.urls.authUri}?scope=$scope&response_type=$responseType&redirect_uri=$redirectUri&client_id=$clientId';

    return url;
  }
}
