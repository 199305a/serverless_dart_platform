import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:angel_route/angel_route.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as json_rpc_2;
import 'package:stream_channel/src/isolate_channel.dart';
import 'request.dart';
import 'response.dart';

/// A simple server class that can either run as a child of some remote parent, or mount an HTTP server.
///
/// Uses the same router as the Angel framework.
class Application {
  final Router<FutureOr<Response> Function(Request)> router = new Router();

  HttpServer _httpServer;
  IsolateChannel _channel;
  json_rpc_2.Server _server;

  Future close() async {
    _httpServer?.close(force: true);
    _channel?.sink?.close();
    _server?.close();
  }

  Future listen(SendPort sendPort, {int port: 0}) async {
    if (sendPort != null) {
      var r = new ReceivePort();
      sendPort.send(r.sendPort);
      _channel = new IsolateChannel(r, sendPort);
      _server = new json_rpc_2.Server(_channel.cast<String>());
      _server.registerMethod('request', (json_rpc_2.Parameters params) async {
        var rq = new Request.fromJson(params.asMap.cast<String, dynamic>());
        var results = router.resolveAbsolute(rq.path, method: rq.method);

        if (results.isEmpty) {
          return new Response(statusCode: 404, text: '404 Not Found');
        } else {
          var pipeline = new MiddlewarePipeline(results);

          for (var result in pipeline.routingResults) {
            rq.routeParameters.addAll(result.allParams);
          }

          for (var handler in pipeline.handlers) {
            try {
              var rs = await handler(rq);
              if (rs != null) {
                return rs;
              }
            } catch (_) {
              return new Response(
                  statusCode: 500, text: '500 Internal Server Error');
            }
          }

          return new Response();
        }
      });

      await _server.listen();
    } else {
      // In development, just mount an HTTP server.
      _httpServer = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
      _httpServer.listen((request) async {
        var response = request.response;
        var headers = <String, String>{};
        request.headers
            .forEach((k, _) => headers[k] = request.headers.value(k));
        var rq = new Request(
            path: request.uri.path,
            method: request.method,
            headers: headers,
            routeParameters: {});

        var results = router.resolveAbsolute(rq.path, method: request.method);

        if (results.isEmpty) {
          response
            ..statusCode = 404
            ..write('404 Not Found')
            ..close();
        } else {
          var pipeline = new MiddlewarePipeline(results);

          for (var result in pipeline.routingResults) {
            rq.routeParameters.addAll(result.allParams);
          }

          for (var handler in pipeline.handlers) {
            try {
              var rs = await handler(rq);

              if (rs != null) {
                response.statusCode = rs.statusCode;
                rs.headers?.forEach(response.headers.add);
                if (rs.text != null)
                  response.write(rs.text);
                else if (rs.body != null) response.add(rs.body);
                break;
              }
            } catch (_) {
              response
                ..statusCode = 500
                ..write('500 Internal Server Error');
            }
          }

          response.close();
        }
      });

      var url = new Uri(
          scheme: 'http',
          host: _httpServer.address.address,
          port: _httpServer.port);
      print('Development server listening at $url');
    }
  }
}
