import 'dart:io';

Future<String> getApiKey() {
  Future<String> contents = File('./secrets/api_key').readAsString();
  return contents;
}
