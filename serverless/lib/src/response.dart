import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
part 'response.g.dart';

@JsonSerializable()
class Response {
  Map<String, String> headers;

  int statusCode;

  List<int> body;

  String text;

  Response(
      {this.headers: const {}, this.statusCode: 200, this.body, this.text});

  factory Response.json(value,
          {Map<String, String> headers: const {}, int statusCode: 200}) =>
      new Response(
          text: json.encode(value),
          headers: {'content-type': 'application/json'}..addAll(headers ?? {}),
          statusCode: statusCode);

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}
