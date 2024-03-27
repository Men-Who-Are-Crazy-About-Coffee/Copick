// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Board _$BoardFromJson(Map<String, dynamic> json) => Board(
      index: json['index'] as int?,
      userId: json['userId'] as int?,
      userNickname: json['userNickname'] as String?,
      userProfileImage: json['userProfileImage'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      domain: json['domain'] as String?,
      regDate: json['regDate'] as String?,
    );

Map<String, dynamic> _$BoardToJson(Board instance) => <String, dynamic>{
      'index': instance.index,
      'userId': instance.userId,
      'userNickname': instance.userNickname,
      'userProfileImage': instance.userProfileImage,
      'title': instance.title,
      'content': instance.content,
      'domain': instance.domain,
      'regDate': instance.regDate,
    };
