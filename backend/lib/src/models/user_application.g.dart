// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_application.dart';

// **************************************************************************
// JsonModelGenerator
// **************************************************************************

@generatedSerializable
class UserApplication extends _UserApplication {
  UserApplication(
      {this.id, this.name, this.path, this.createdAt, this.updatedAt});

  @override
  final String id;

  @override
  final String name;

  @override
  final String path;

  @override
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  UserApplication copyWith(
      {String id,
      String name,
      String path,
      DateTime createdAt,
      DateTime updatedAt}) {
    return new UserApplication(
        id: id ?? this.id,
        name: name ?? this.name,
        path: path ?? this.path,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt);
  }

  bool operator ==(other) {
    return other is _UserApplication &&
        other.id == id &&
        other.name == name &&
        other.path == path &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  Map<String, dynamic> toJson() {
    return UserApplicationSerializer.toMap(this);
  }
}
