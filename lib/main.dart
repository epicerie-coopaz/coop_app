import 'package:coopaz_app/auth.dart';
import 'package:coopaz_app/conf.dart';
import 'package:coopaz_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:coopaz_app/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  log('Init AuthManager...');

  var conf = Conf();

  var authManager = AuthManager(conf: conf);
  await authManager.init();

  log('Starting Coopaz app...');
  runApp(CoopazApp(conf: conf, authManager: authManager));
  log('App started !');
}
