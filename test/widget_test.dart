// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:coopaz_app/auth.dart';
import 'package:coopaz_app/conf.dart';
import 'package:coopaz_app/dao/memberDao.dart';
import 'package:coopaz_app/dao/orderDao.dart';
import 'package:coopaz_app/dao/productDao.dart';
import 'package:coopaz_app/screens/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    var conf = Conf();

    var authManager = AuthManager(conf: conf);
    await authManager.init();

    var memberDao = MemberDao(
        googleSheetUrlApi: conf.urls.googleSheetsApi,
        spreadSheetId: conf.spreadSheetId,
        authManager: authManager);

    var productDao = ProductDao(
        googleSheetUrlApi: conf.urls.googleSheetsApi,
        spreadSheetId: conf.spreadSheetId,
        authManager: authManager);

    var orderDao = OrderDao(
        googleAppsScriptUrlApi: conf.urls.googleAppsScriptApi,
        appsScriptId: conf.appsScriptId,
        authManager: authManager);

    // Build our app and trigger a frame.
    await tester.pumpWidget(CoopazApp(
      memberDao: memberDao,
      orderDao: orderDao,
      productDao: productDao,
    ));
  });
}
