import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:fe/src/models/user.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/services/user_provider.dart';
import 'package:fe/src/widgets/board_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/comment_container.dart';
import '../widgets/liked_board_container.dart';

enum ProfileContentType {
  board(type: "게시글",size: 5),
  comment(type: "댓글",size: 10),
  like(type: "좋아요",size: 10);

  final String type;
  final int size;

  const ProfileContentType({
    required this.type,
    required this.size
  });
}

class ProfileContentProvider extends ChangeNotifier {
  List<Widget> items = [];
  int currentIndex = 0;
  int endPage = 1;
  bool isMore = false;
  bool _isLoading = true;
  late User user;
  late ProfileContentType contentType = ProfileContentType.board;

  get isLoading => _isLoading;

  int size = 5;
  ApiService apiService = ApiService();

  Future<void> started(ProfileContentType contentType, {required User user ,int? s}) async {
    size = s ?? contentType.size;
    switch (contentType) {
      case ProfileContentType.board:
        Response response = await apiService
            .get('/api/board/my/posts?size=$size&page=$currentIndex');
        var boards = response.data['list'];
        endPage = response.data['totalPages'];
        _isLoading = false;
        for (var board in boards) {
          String userImg = "";
          board['userProfileImage'] == null
              ? userImg =
          "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png"
              : userImg = board['userProfileImage'];
          items.add(
            BoardContainer(
              index: board['index'],
              userId: board['userId'],
              coffeeImg: board['images'],
              // 이 부분은 실제 데이터에 맞게 조정하세요
              memberNickName: board['userNickname'],
              memberImg: userImg,
              title: board['title'],
              content: board['content'],
              like: board['likes'],
              isLiked: board['liked'],
              commentCnt: board['comments'],
              regDate: board['regDate'],
            ),
          );
        }
      case ProfileContentType.comment:
        Response response = await apiService.get(
            '/api/comment/user/${user.index}?size=$size&page=$currentIndex');
        var comments = response.data['list'];
        for (var comment in comments) {
          String userImg = "";
          comment['memberPrifileImage'] == null
              ? userImg =
          "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png"
              : userImg = comment['memberPrifileImage'];

          items.add(
              CommentContainer(
                index: comment['index'],
                boardIndex: comment['boardIndex'],
                userId: comment['memberIndex'],
                memberNickName: comment['memberName'],
                isProfile: true,
                memberImg: userImg,
                content: comment['content'],
                regDate: comment['regDate'],
              ));
        }
      case ProfileContentType.like:
        Response response = await apiService.get(
            '/api/board/my/posts?size=$size&page=$currentIndex');
        var likedBoards = response.data['list'];
        for (var board in likedBoards) {
          String userImg = "";
          board['userPrifileImage'] == null
              ? userImg =
          "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png"
              : userImg = board['userPrifileImage'];

          items.add(
              LikedBoardContainer(
                index: board['index'],
                userId: board['userId'],
                memberNickName: board['userNickname'],
                coffeeImg: board['images'],
                memberImg: userImg,
                content: board['content'],
                regDate: board['regDate'],
                title: board['title'],
                isLiked: board['isLiked'],
                like: board['like'],
                commentCnt: board['commentCnt'],
              ));
        }
      default:
        print("유효하지 않은 컨텐츠 타입 선언");
    }

    currentIndex = 1;
    notifyListeners();


  }

  Future<void> _addItem() async {
    if (!isMore) {
      isMore = true;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 500), () async {
        switch (contentType) {
          case ProfileContentType.board:
            Response response = await apiService.get(
                '/api/board/my/posts?size=$size&page=$currentIndex');
            var boards = response.data['list'];
            for (var board in boards) {
              String userImg = "";
              board['userProfileImage'] == null
                  ? userImg =
              "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png"
                  : userImg = board['userProfileImage'];

              items.add(
                  BoardContainer(
                    index: board['index'],
                    userId: board['userId'],
                    coffeeImg: board['images'],
                    // 이 부분은 실제 데이터에 맞게 조정하세요
                    memberNickName: board['userNickname'],
                    memberImg: userImg,
                    title: board['title'],
                    content: board['content'],
                    like: board['likes'],
                    isLiked: board['liked'],
                    commentCnt: board['comments'],
                    regDate: board['regDate'],
                  ));
            }
          case ProfileContentType.comment:
            Response response = await apiService.get(
                '/api/board/my/posts?size=$size&page=$currentIndex');
            var comments = response.data['list'];
            for (var comment in comments) {
              String userImg = "";
              comment['userPrifileImage'] == null
                  ? userImg =
              "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png"
                  : userImg = comment['userPrifileImage'];

              items.add(
                  CommentContainer(
                    index: comment['index'],
                    boardIndex: comment['boardIndex'],
                    userId: comment['userId'],
                    memberNickName: comment['userNickname'],
                    isProfile: true,
                    memberImg: userImg,
                    content: comment['content'],
                    regDate: comment['regDate'],
                  ));
            }
          case ProfileContentType.like:
            Response response = await apiService.get(
                '/api/board/my/posts?size=$size&page=$currentIndex');
            var likedBoards = response.data['list'];
            for (var board in likedBoards) {
              String userImg = "";
              board['userPrifileImage'] == null
                  ? userImg =
              "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png"
                  : userImg = board['userPrifileImage'];

              items.add(
                  LikedBoardContainer(
                    index: board['index'],
                    userId: board['userId'],
                    memberNickName: board['userNickname'],
                    coffeeImg: board['images'],
                    memberImg: userImg,
                    content: board['content'],
                    regDate: board['regDate'],
                    title: board['title'],
                    isLiked: board['isLiked'],
                    like: board['like'],
                    commentCnt: board['commentCnt'],
                  ));
            }
          default:
            print("유효하지 않은 컨텐츠 타입 선언");
      }
        currentIndex = currentIndex + 1;
        isMore = false;
        notifyListeners();
      }
      );
    }
  }

  void listner(ScrollUpdateNotification notification) {
    if (notification.metrics.maxScrollExtent * 0.85 <
        notification.metrics.pixels &&
        currentIndex < endPage) {
      _addItem();
    }
  }
}
