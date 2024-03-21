import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fe/src/models/board.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/widgets/board_container.dart';
import 'package:fe/src/screens/community_write_page.dart';
import 'package:flutter/material.dart';

class CommunityPage extends StatelessWidget {
  String memberImg =
      "https://cdn.ceomagazine.co.kr/news/photo/201802/1714_4609_1642.jpg";
  String memberNickName = "이호성";
  String coffeeImg =
      "https://d3kgrlupo77sg7.cloudfront.net/media/chococoorgspice.com/images/products/coorg-arabica-roasted-coffee-beans.20231001174407.webp";
  String comment = "ㅎㅇ";
  bool isLiked = true;
  int like = 1;

  Future<List<dynamic>> getCommunityList() async {
    ApiService apiService = ApiService();
    Response response =
        await apiService.get('/api/board/search?domain=GENERAL');
    print(response.data['list']);
    return response.data['list'];
  }

  CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    getCommunityList();
    return Scaffold(
      appBar: AppBar(title: const Text('자유 게시판')),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 20),
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/community_write'),
                  icon: const Icon(Icons.post_add),
                ),
                FutureBuilder<List<dynamic>>(
                  future: getCommunityList(), // 비동기 데이터 로드
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // 데이터 로딩 중
                    } else if (snapshot.hasError) {
                      return Text("에러가 발생했습니다: ${snapshot.error}");
                    } else {
                      // 데이터 로드 성공
                      var boards = snapshot.data!; // 'boardList' 데이터 활용
                      List<Widget> boardWidgets = [];
                      for (var board in boards) {
                        final List<dynamic> contents =
                            json.decode(board['content']);
                        for (var content in contents) {
                          print(content);
                        }
                        boardWidgets.add(
                          BoardContainer(
                            coffeeImg: coffeeImg, // 이 부분은 실제 데이터에 맞게 조정하세요
                            memberNickName: board['userNickname'],
                            memberImg: memberImg,
                            comment: comment,
                            like: like,
                            isLiked: isLiked,
                          ),
                        );
                      }
                      return Column(children: boardWidgets);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
