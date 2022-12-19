import 'package:coopaz_app/auth.dart';
import 'package:coopaz_app/conf.dart';
import 'package:test/test.dart';

main() {
  test('Test generateCodeVerifier', () {
    var randomString = AuthManager(conf: Conf()).generateCodeVerifier();

    expect(randomString, (String s) {
      return s.length >= 43 && s.length <= 128;
    });
  });

  test('Test getAuth', () async {
    String response = await AuthManager(conf: Conf()).getAuthUrl();

    expect(response, (String s) {
      return s.isNotEmpty;
    });
  });
}
