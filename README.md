# serverless_dart_platform
A **minimal** PoC for a Dart-based FaaS provider.

If interest is high enough (kinda doubt it),
I might consider actually developing a derivative of this into a
Lambda-like serverless platform for Dart functions.

The concept is simple:
* Store user/guest apps in separate directories
* Launch one isolate for each application, when said application is called
* Using JSON RPC, send/receive requests/responses.

The repo is split into three parts:
* `apps/` - The child apps; they basically just contain functions that are triggered
by an HTTP request. Users would test locally, upload to your server, and just pay for
uptime. *You* would do the sysadmin for them.
* `backend/` - [Angel 2.0](https://angel-dart.github.io) backend, manages isolates and dispatches requests.
* `serverless/` - The common protocol/API for data transfer.

`package:serverless` in this repo provides a simple API that uses the
[Angel](https://angel-dart.github.io) router, and sends responses either along a `SendPort`, or automatically
mounts an HTTP server in development sitations, for local testing:

```dart
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
```

## Setup
1. Install [`pkg:mono_repo`](https://github.com/dart-lang/mono_repo).
2. Run `mono_repo pub get` in root dir.
3. Run `mono_repo pub get` in `apps/` dir.

## Starting the Server
1. `cd backend`
2. `dart --observe bin/dev.dart`. (`--observe` is optional; it enables hot reloading)

You can then visit routes from the `hello` app:
* http://localhost:3000/apps/hello/greet/tobe
* http://localhost:3000/apps/hello/nonexistent_route

## Adding an App
1. Create a project, anywhere on the disk. Ideally, though, you'll
put this in the `apps/` dir, for the purposes of this demo.
2. Add an entry to `backend/src/db/apps.json`, containing a `name` and the `path` to the directory, relative to `backend/`.

In development mode, the `Application` class will just mount a small HTTP server.
For example, run `cd apps/hello && dart bin/main.dart`.

## Considerations
* This PoC implementation should be kept far away from production, as
it is almost entirely insecure.
* In reality, you'd more than likely create separate unprivileged users
for each app/organization, and use `chmod` to prevent malicious users from tampering
with other tenants' files.
* Don't run your business database on the same server as guest applications. If you do,
at least apply some password-protection, so nobody can do anything pesky. Keep in mind
that any user can install any package, including database drivers.
* User applications are run in the same VM as your application, rather than within
separate processes. This isn't that bad, because Dart isolates share nothing, BUT
the getter `Directory.current` applies ACROSS ALL ISOLATES. *That* is something
to keep in mind.
    * This also implies that users can't pick their own Dart VM version.
* The VM run by guest apps is not sandboxed at all.