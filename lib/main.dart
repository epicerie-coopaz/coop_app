import 'package:coopaz_app/auth.dart';
import 'package:coopaz_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:coopaz_app/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  log('Get auth...');

  var authManager = AuthManager();
  await authManager.initManager();

  log('Starting Coopaz app...');
  runApp(CoopazApp(authManager: authManager));
  log('App started !');
}
