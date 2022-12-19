import 'dart:convert';
import 'dart:io';
import 'package:coopaz_app/conf.dart';
import 'package:crypto/crypto.dart';
import 'package:coopaz_app/logger.dart';
import 'package:http/http.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

class AuthManager {
  AuthManager({required this.conf});

  Conf conf;

  String? authCode;
  String? clientId;
  String? clientSecret;
  String? redirectUri;
  String responseType = 'code';
  String scope = 'https://www.googleapis.com/auth/spreadsheets';
  String? refreshToken;
  String? accessToken;
  // String codeChallenge = generateChallenge();
  // String codeChallengeMethod = 'S256';

  Future init() async {
    clientId = conf.clientId;
    clientSecret = conf.clientSecret;
    redirectUri = conf.urls.redirectUris;
  }

  Future<String> getAccessToken() async {
    if (refreshToken == null) {
      await _getRefreshToken();
    }
    if (accessToken == null) {
      final response = await post(Uri.parse(conf.urls.tokenUri),
          headers: {
            "Accept": "application/json",
          },
          body:
              'client_id=$clientId&client_secret=$clientSecret&grant_type=refresh_token&refresh_token=$refreshToken');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to get access token: [${response.statusCode}] ${response.body}');
      }

      var body = jsonDecode(response.body);

      accessToken = body['access_token'];
      log('New access token received: $accessToken');
    }

    return accessToken!;
  }

  Future _getRefreshToken() async {
    if (authCode == null) {
      await _getAuth();
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
  }

  Future _getAuth() async {
    final url = await getAuthUrl();
    log('Get auth url: $url');

    final uri = Uri.parse(url);
    await launchUrl(uri);

    var server = await HttpServer.bind(InternetAddress.anyIPv6, 8080);
    var requestFromGoogle = await server.first;

    authCode = requestFromGoogle.uri.queryParameters['code'];
    if (authCode != null) {
      requestFromGoogle.response
          .write('Auth ok! Tu peux fermer cette fenêtre mon lapin. <3');
      log('New auth code received: $authCode');
    } else {
      requestFromGoogle.response
          .write('Auth ko... Pas de code d\'auth reçu... :(');
    }

    requestFromGoogle.response.close();
  }

  Future<String> getAuthUrl() async {
    // String url = '$googleAuthUrl?scope=$scope&response_type=$responseType&redirect_uri=$redirectUri&client_id=$clientId&code_challenge=$codeChallenge&code_challenge_method=$codeChallengeMethod';
    String url =
        '${conf.urls.authUri}?scope=$scope&response_type=$responseType&redirect_uri=$redirectUri&client_id=$clientId';

    return url;
  }

  String generateChallenge() {
    String codeVerifier = generateCodeVerifier();
    List<int> aciiBytes = ascii.encode(codeVerifier);
    List<int> hash = sha256.convert(aciiBytes).bytes;
    String challenge = base64Encode(hash).toString();
    return challenge;
  }

  String generateCodeVerifier() {
    Random rnd = Random();

    // Generate a random length between 43 and 128
    int length = rnd.nextInt(85) + 43;
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890-._~';

    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
