// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      index: json['index'] as int? ?? 0,
      id: json['id'] as String? ?? '',
      role: json['role'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'index': instance.index,
      'id': instance.id,
      'role': instance.role,
      'nickname': instance.nickname,
      'profileImage': instance.profileImage,
    };
