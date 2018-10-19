// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Response _$ResponseFromJson(Map<String, dynamic> json) {
  return Response(
      headers: (json['headers'] as Map<String, dynamic>)
          ?.map((k, e) => MapEntry(k, e as String)),
      statusCode: json['statusCode'] as int,
      body: (json['body'] as List)?.map((e) => e as int)?.toList(),
      text: json['text'] as String);
}

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'headers': instance.headers,
      'statusCode': instance.statusCode,
      'body': instance.body,
      'text': instance.text
    };
