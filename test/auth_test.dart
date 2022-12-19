import 'package:coopaz_app/auth.dart';
import 'package:coopaz_app/conf.dart';
import 'package:test/test.dart';

main() {

  test('Test getAuthUrl', () async {
    String response = await AuthManager(conf: Conf()).getAuthUrl();

    expect(response, (String s) {
      return s.isNotEmpty;
    });
  });
}
