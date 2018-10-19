import 'package:angel_file_service/angel_file_service.dart';
import 'package:angel_framework/angel_framework.dart';
import 'package:file/file.dart';

AngelConfigurer configureServer(Directory dbDirectory) {
  return (Angel app) async {
    app.use('/api/user_applications',
        new JsonFileService(dbDirectory.childFile('apps.json')));
  };
}
