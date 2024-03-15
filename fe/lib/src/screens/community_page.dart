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

  CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    icon: const Icon(Icons.post_add)),
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
      ),
    );
  }
}
