import 'dart:convert';
import 'dart:io';
import 'package:coopaz_app/constants.dart';
import 'package:crypto/crypto.dart';
import 'package:coopaz_app/logger.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

class AuthManager {
  AuthManager(
      {this.apiKeyFilePath = './secrets/api_key',
      this.authFilePath = './secrets/google.oauth.json'});

  String authFilePath;
  String apiKeyFilePath;
  String? authCode;

  Future getAuth() async {
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
    } else {
      requestFromGoogle.response
          .write('Auth ko... Pas de code d\'auth reçu... :(');
    }

    requestFromGoogle.response.close();
  }

  Future<String> getApiKey() {
    Future<String> contents = File(apiKeyFilePath).readAsString();
    return contents;
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

  Future<String> getAuthUrl() async {
    String authFile = await File(authFilePath).readAsString();
    var authJson = jsonDecode(authFile);

    String clientId = authJson['installed']['client_id'];
    String redirectUri = authJson['installed']['redirect_uris'][0];
    String responseType = 'code';
    String scope = 'https://www.googleapis.com/auth/spreadsheets';
    // String codeChallenge = generateChallenge();
    // String codeChallengeMethod = 'S256';
    // String url = '$googleAuthUrl?scope=$scope&response_type=$responseType&redirect_uri=$redirectUri&client_id=$clientId&code_challenge=$codeChallenge&code_challenge_method=$codeChallengeMethod';
    String url =
        '$googleAuthUrl?scope=$scope&response_type=$responseType&redirect_uri=$redirectUri&client_id=$clientId';

    return url;
  }
}
