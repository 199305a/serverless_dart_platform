// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Request _$RequestFromJson(Map<String, dynamic> json) {
  return Request(
      headers: (json['headers'] as Map<String, dynamic>)
          ?.map((k, e) => MapEntry(k, e as String)),
      routeParameters: json['route_parameters'] as Map<String, dynamic>,
      path: json['path'] as String,
      method: json['method'] as String,
      body: json['body']);
}

Map<String, dynamic> _$RequestToJson(Request instance) {
  var val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('headers', instance.headers);
  writeNotNull('route_parameters', instance.routeParameters);
  writeNotNull('path', instance.path);
  writeNotNull('method', instance.method);
  writeNotNull('body', instance.body);
  return val;
}
