import 'package:fe/src/screens/board_container.dart';
import 'package:flutter/material.dart';

class BoardListPage extends StatelessWidget {
  String memberImg =
      "https://cdn.ceomagazine.co.kr/news/photo/201802/1714_4609_1642.jpg";
  String memberNickName = "이호성";
  String coffeeImg =
      "https://d3kgrlupo77sg7.cloudfront.net/media/chococoorgspice.com/images/products/coorg-arabica-roasted-coffee-beans.20231001174407.webp";
  String comment = "ㅎㅇ";
  bool isLiked = true;
  int like = 1;

  BoardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Row(
                children: [
                  SizedBox(width: 20),
                  Text(
                    "자유 게시판",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              BoardContainer(
                coffeeImg: coffeeImg,
                memberNickName: memberNickName,
                memberImg: memberImg,
                comment: comment,
                like: like,
                isLiked: isLiked,
              ),
              BoardContainer(
                coffeeImg: coffeeImg,
                memberImg: memberImg,
                memberNickName: memberNickName,
                comment: comment,
                like: like,
                isLiked: isLiked,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
