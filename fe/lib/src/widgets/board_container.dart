import 'package:fe/constants.dart';
import 'package:flutter/material.dart';

class BoardContainer extends StatefulWidget {
  final String memberImg;
  final String memberNickName;
  final List<dynamic> coffeeImg;
  final String comment;
  final bool isLiked;
  final int like;

  const BoardContainer({
    super.key,
    required this.memberImg,
    required this.memberNickName,
    required this.coffeeImg,
    required this.comment,
    required this.isLiked,
    required this.like,
  });

  @override
  State<BoardContainer> createState() => _BoardContainerState();
}

class _BoardContainerState extends State<BoardContainer> {
  String? memberImg;
  String? memberNickName;
  String? coffeeImg;
  String? comment;
  bool isLiked = false;
  int? like;

  @override
  void initState() {
    super.initState();
    memberImg = widget.memberImg;
    memberNickName = widget.memberNickName;
    coffeeImg = widget.coffeeImg[0];
    comment = widget.comment;
    isLiked = widget.isLiked;
    like = widget.like;
  }

  ThemeColors themeColors = ThemeColors();

  void _showCommentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('댓글'),
          content: const Text('댓글 기능이 여기에 구현됩니다.'),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // border: Border.all(width: 1, color: Colors.black),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 10),
                ClipOval(
                  child: Image.network(
                    widget.memberImg,
                    height: 20,
                    width: 20,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 20),
                Text("$memberNickName")
              ],
            ),
            const SizedBox(height: 10),
            Image.network(
              coffeeImg!,
              fit: BoxFit.scaleDown,
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked
                        ? Icons.coffee_outlined
                        : Icons.coffee_sharp, // '좋아요' 상태에 따라 아이콘 변경
                    color: isLiked
                        ? Colors.grey
                        : themeColors.color5, // '좋아요' 상태에 따라 아이콘 색상 변경
                  ),
                  onPressed: () {
                    setState(() {
                      isLiked = !isLiked; // 버튼을 탭할 때마다 '좋아요' 상태 토글
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.mode_comment_outlined,
                    color: Colors.grey,
                  ),
                  onPressed:
                      _showCommentDialog, // 댓글 아이콘을 탭할 때 _showCommentDialog 함수를 호출
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("좋아요 "),
                      Text("$like"),
                      const Text("개"),
                    ],
                  ),
                  Row(
                    children: [
                      Text("$comment"),
                    ],
                  ),
                ],
              ),
            )
          ],
        ), //전체 컬럼
      ),
    );
  }
}
