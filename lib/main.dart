import 'package:coopaz_app/auth.dart';
import 'package:coopaz_app/conf.dart';
import 'package:coopaz_app/dao/member_dao.dart';
import 'package:coopaz_app/dao/order_dao.dart';
import 'package:coopaz_app/dao/product_dao.dart';
import 'package:coopaz_app/ui/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:coopaz_app/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  log('Init AuthManager...');

  var conf = Conf();

  var authManager = AuthManager(conf: conf);
  await authManager.init();
  await authManager.getRefreshToken();

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

  log('Starting Coopaz app...');
  runApp(CoopazApp(
    memberDao: memberDao,
    orderDao: orderDao,
    productDao: productDao,
  ));
  log('App started !');
}
