import 'dart:async';
import 'dart:isolate';
import 'package:async/async.dart';
import 'package:file/file.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as json_rpc_2;
import 'package:path/path.dart' as p;
import 'package:pooled_map/pooled_map.dart';
import 'package:serverless/serverless.dart';
import 'package:stream_channel/stream_channel.dart';

class AppHost {
  final Directory appsDirectory;
  final PooledMap<String, GuestApp> _apps = new PooledMap();

  AppHost(this.appsDirectory);

  Future close() async {
    for (var app in await _apps.values) {
      await app._close();
    }

    await _apps.clear();
  }

  Future<GuestApp> getApp(String name) async {
    return _apps.putIfAbsent(name, () async {
      var dir = p.absolute(p.join(appsDirectory.path, name));
      var mainFile = p.toUri(p.join(dir, 'bin', 'main.dart'));
      var packageConfig = p.toUri(p.join(dir, '.packages'));
      var recv = new ReceivePort();
      var isolate = await Isolate.spawnUri(mainFile, [], recv.sendPort,
          packageConfig: packageConfig);
      var app =
          new GuestApp._(appsDirectory.childDirectory(name), isolate, recv);
      await app._start();
      return app;
    });
  }
}

class GuestApp {
  final Directory _directory;
  final Isolate _isolate;
  final ReceivePort _receivePort;
  json_rpc_2.Client _client;

  GuestApp._(this._directory, this._isolate, this._receivePort);

  Future<Response> handleRequest(Request rq) {
    return _client
        .sendRequest('request', rq.toJson())
        .then((r) => new Response.fromJson(r as Map<String, dynamic>));
  }

  Future _close() async {
    _client?.close();
    _receivePort?.close();
    _isolate?.kill();
  }

  Future _start() async {
    var q = new StreamQueue(_receivePort);
    var sp = await q.next as SendPort;
    var ctrl = new StreamChannelController();
    ctrl.local.stream.listen(sp.send);
    q.rest.listen(ctrl.local.sink.add);
    _client = new json_rpc_2.Client(ctrl.foreign.cast<String>());
    _client.listen();
  }
}
