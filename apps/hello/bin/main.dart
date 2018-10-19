import 'dart:isolate';
import 'package:serverless/serverless.dart';

main(_, [SendPort sendPort]) async {
  var app = new Application();

  app.router.get('/greet/:name', (req) {
    // Returns {"name": <name>}
    return new Response.json(req.routeParameters);
  });

  // Respond to all requests with some JSON.
  app.router.all('*', (req) {
    return new Response.json({'hello': 'serverless world!'});
  });

  // Start listening for incoming request. In production, information about
  // a request would be sent to this isolate from the main server via a SendPort.
  //
  // If `sendPort` is null (i.e. in dev), this will mount an HTTP server instead.
  app.listen(sendPort, port: 3001);
}
