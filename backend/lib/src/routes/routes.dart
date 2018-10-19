library backend.src.routes;

import 'package:angel_file_service/angel_file_service.dart';
import 'package:angel_framework/angel_framework.dart';
import 'package:file/file.dart';
import 'package:serverless/serverless.dart';
import '../models/models.dart';
import '../app_host.dart';

AngelConfigurer configureServer(FileSystem fileSystem) {
  return (Angel app) async {
    app.all('/apps/:name/:path(.+)', (req, res) async {
      // Read the request parameters.
      var name = req.params['name'] as String,
          path = req.params['path'] as String;

      // Find the app in question.
      var userAppsService =
          app.findHookedService<JsonFileService>('/api/user_applications');
      var params = {
        'query': {'name': name}
      };
      var userAppModel = await userAppsService.inner
          .findOne(params, 'No app named "$name" exists.')
          .then((m) => UserApplicationSerializer.fromMap(m as Map));

      // Using our AppHost class, find or start an isolate for this app.
      var guestApp =
          await req.container.make<AppHost>().getApp(userAppModel.name);

      var body, headers = <String, String>{};

      if (const ['POST', 'PATCH'].contains(req.method))
        body = await req.parseBody();

      req.headers.forEach((k, _) => headers[k] = req.headers.value(k));

      // Make a request object
      var request = new Request(
          method: req.method,
          routeParameters: {},
          headers: headers,
          body: body,
          path: path);

      // Get the response, and send it out.
      var response = await guestApp.handleRequest(request);
      res
        ..statusCode = response.statusCode
        ..headers.addAll(response.headers);

      if (response.text != null) {
        res.write(response.text);
      } else if (response.body != null) {
        res.add(response.body);
      }

      res.close();
    });

    // Throw a 404 if no route matched the request.
    app.fallback((req, res) => throw new AngelHttpException.notFound());
  };
}
