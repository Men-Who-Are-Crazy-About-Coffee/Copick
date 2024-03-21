import 'package:dio/dio.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/widgets/board_container.dart';
import 'package:flutter/material.dart';

class BoardProvider extends ChangeNotifier {
  List<Widget> items = [];
  int currentIndex = 0;
  bool isMore = false;

  // Future<void> pageViewItems({
  //   bool isStart = true,
  // }) async {
  //   if (!isMore) {
  //     isMore = true;
  //     notifyListeners();
  //     Future.delayed(Duration(milliseconds: isStart ? 0 : 2000), () {
  //       for (int i = 0; i < 3; i++) {
  //         items
  //             .add('https://picsum.photos/id/${i + currentIndex + 50}/300/400');
  //       }
  //       currentIndex = currentIndex + 3;
  //       isMore = false;
  //       notifyListeners();
  //     });
  //   }
  // }

  // Future<void> changedPage(int index) async {
  //   if (index == currentIndex) {
  //     pageViewItems(isStart: false);
  //   }
  // }

  int size = 5;
  ApiService apiService = ApiService();

  Future<void> started() async {
    Response response = await apiService
        .get('/api/board/search?domain=GENERAL&size=$size&page=0');
    var boards = response.data['list'];
    for (var board in boards) {
      String userImg = "";
      board['userProfileImage'] == null
          ? userImg =
              "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png"
          : userImg = board['userProfileImage'];
      items.add(
        BoardContainer(
          coffeeImg: board['images'], // 이 부분은 실제 데이터에 맞게 조정하세요
          memberNickName: board['userNickname'],
          memberImg: userImg,
          comment: board['content'],
          like: 1,
          isLiked: false,
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
        for (var board in boards) {
          String userImg = "";
          board['userProfileImage'] == null
              ? userImg =
                  "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png"
              : userImg = board['userProfileImage'];
          items.add(
            BoardContainer(
              coffeeImg: board['images'], // 이 부분은 실제 데이터에 맞게 조정하세요
              memberNickName: board['userNickname'],
              memberImg: userImg,
              comment: board['content'],
              like: 1,
              isLiked: false,
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
