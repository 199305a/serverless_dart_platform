import 'package:json_annotation/json_annotation.dart';
part 'request.g.dart';

@JsonSerializable()
class Request {
  @JsonKey(name: 'headers', includeIfNull: false)
  Map<String, String> headers;

  @JsonKey(name: 'route_parameters', includeIfNull: false)
  Map<String, dynamic> routeParameters;

  @JsonKey(name: 'path', includeIfNull: false)
  String path;

  @JsonKey(name: 'method', includeIfNull: false)
  String method;

  @JsonKey(name: 'body', includeIfNull: false)
  Object body;

  Map<String, dynamic> states = {};

  Request(
      {this.headers: const {},
      this.routeParameters: const {},
      this.path,
      this.method,
      this.body});

  Map<String, dynamic> get bodyAsMap => body as Map<String, dynamic>;

  factory Request.fromJson(Map<String, dynamic> json) =>
      _$RequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestToJson(this);
}
