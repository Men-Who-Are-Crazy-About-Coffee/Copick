import 'package:json_annotation/json_annotation.dart';

part 'board.g.dart';

@JsonSerializable()
class Board {
  final int? index;
  final int? userId;
  final String? userNickname;
  final String? userProfileImage;
  final String? title;
  final String? content;
  final String? domain;
  final String? regDate;

  Board({
    this.index,
    this.userId,
    this.userNickname,
    this.userProfileImage,
    this.title,
    this.content,
    this.domain,
    this.regDate,
  });

  // JSON 직렬화 및 역직렬화를 위한 메서드
  factory Board.fromJson(Map<String, dynamic> json) => _$BoardFromJson(json);
  Map<String, dynamic> toJson() => _$BoardToJson(this);
}
