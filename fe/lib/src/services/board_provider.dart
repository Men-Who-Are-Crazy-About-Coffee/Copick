import 'package:dio/dio.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/widgets/board_container.dart';
import 'package:flutter/material.dart';

class BoardProvider extends ChangeNotifier {
  List<Widget> items = [];
  int currentIndex = 0;
  bool isMore = false;

  int size = 5;
  ApiService apiService = ApiService();

  Future<void> started() async {
    Response response = await apiService
        .get('/api/board/search?domain=GENERAL&size=$size&page=0');
    var boards = response.data['list'];
    // print(boards);
    for (var board in boards) {
      String userImg = "";
      board['userProfileImage'] == null
          ? userImg =
              "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png"
          : userImg = board['userProfileImage'];
      items.add(
        BoardContainer(
          index: board['index'],
          coffeeImg: board['images'], // 이 부분은 실제 데이터에 맞게 조정하세요
          memberNickName: board['userNickname'],
          memberImg: userImg,
          title: board['title'],
          content: board['content'],
          like: board['likes'],
          isLiked: board['liked'],
        ),
      );
    }
    currentIndex = 1;
    notifyListeners();
  }

  Future<void> _addItem() async {
    if (!isMore) {
      isMore = true;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 500), () async {
        Response response = await apiService.get(
            '/api/board/search?domain=GENERAL&size=$size&page=$currentIndex');
        var boards = response.data['list'];
        print(boards);
        for (var board in boards) {
          String userImg = "";
          board['userProfileImage'] == null
              ? userImg =
                  "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png"
              : userImg = board['userProfileImage'];
          items.add(
            BoardContainer(
              index: board['index'],
              coffeeImg: board['images'], // 이 부분은 실제 데이터에 맞게 조정하세요
              memberNickName: board['userNickname'],
              memberImg: userImg,
              title: board['title'],
              content: board['content'],
              like: board['likes'],
              isLiked: board['liked'],
            ),
          );
        }
        currentIndex = currentIndex + 1;
        isMore = false;
        notifyListeners();
      });
    }
  }

  void listner(ScrollUpdateNotification notification) {
    if (notification.metrics.maxScrollExtent * 0.85 <
        notification.metrics.pixels) {
      _addItem();
    }
  }
}