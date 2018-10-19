library backend.services;

import 'package:angel_framework/angel_framework.dart';
import 'package:file/file.dart';
import 'user_application.dart' as user_application;

AngelConfigurer configureServer(FileSystem fs) {
  return (Angel app) async {
    var dbDirectory = fs.directory('db');
    await app.configure(user_application.configureServer(dbDirectory));
  };
}
