import 'package:dio/dio.dart';
import 'package:fe/constants.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'comment_container.dart';

class BoardContainer extends StatefulWidget {
  final int index;
  final String? memberImg;
  final String? memberNickName;
  final List<dynamic> coffeeImg;
  final String title;
  final String content;
  final bool isLiked;
  final int like;
  final int userId;
  final int commentCnt;
  final String regDate;

  const BoardContainer(
      {super.key,
      required this.index,
      required this.userId,
      required this.memberImg,
      required this.memberNickName,
      required this.coffeeImg,
      required this.title,
      required this.content,
      required this.isLiked,
      required this.like,
      required this.commentCnt,
      required this.regDate});

  @override
  State<BoardContainer> createState() => _BoardContainerState();
}

class _BoardContainerState extends State<BoardContainer> {
  String? _memberImg;
  String? _memberNickName;
  String? _coffeeImg;
  String? _title;
  String? _content;
  bool _isLiked = false;
  int _like = 0;
  int _commentCnt = 0;
  int _userId = 0;
  int? _index;
  bool _isExpanded = false;
  String _regDate = "";
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _memberImg = widget.memberImg;
    _memberNickName = widget.memberNickName;
    _coffeeImg = widget.coffeeImg[0];
    _title = widget.title;
    _content = widget.content;
    _isLiked = widget.isLiked;
    _like = widget.like;
    _index = widget.index;
    _userId = widget.userId;
    _commentCnt = widget.commentCnt;
    _regDate = widget.regDate;
    _commentCnt = widget.commentCnt;
  }

  ThemeColors themeColors = ThemeColors();
  TextEditingController commentController = TextEditingController();
  late List<dynamic> _comments = [];

  void setLike() async {
    apiService.post('/api/board/$_index/like');
  }

  void deleteLike() async {
    apiService.delete('/api/board/$_index/like');
  }

  void deleteBoard() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게시글 삭제'),
          content: const Text('정말 게시글을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('네'),
              onPressed: () async {
                await apiService.delete('/api/board/$_index');
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('아니요'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void unRegister() {}

  void _showModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CommentContainer(
                            userId: _comments[index]["memberIndex"],
                            index: _comments[index]["index"],
                            content: _comments[index]["index"],
                            memberNickName: _comments[index]["memberName"],
                            boardIndex: _comments[index]["boardIndex"],
                            regDate: _comments[index]["regDate"],
                            memberImg: _comments[index]["memberPrifileImage"],

                          )
                                  ],
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                            controller: commentController,
                            decoration: const InputDecoration(
                              hintText: '댓글 추가...',
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          setState(() async {
                            addComment();
                            commentController.clear();
                            Navigator.pop(context);
                          });
                          // 모달을 닫고 싶지 않으면 아래 줄을 주석 처리하세요.
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void addComment() async {
    await apiService.post(
      "/api/comment",
      data: {
        "boardIndex": _index,
        "content": commentController.text,
      },
    );
  }

  void getComment() async {
    Response response =
        await apiService.get("/api/comment/board/$_index?sort=index");
    _comments = response.data['list'];

    _showModalBottomSheet();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context); // Counter 인스턴스에 접근
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
                    _memberImg!,
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Text("$_memberNickName"),
                (_userId == user.user.index) || (user.user.role == "ADMIN")
                    ? Row(
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          TextButton(
                            onPressed: () {
                              deleteBoard();
                            },
                            child: const Text(
                              "삭제",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      )
                    : const Text("")
              ],
            ),
            const SizedBox(height: 10),
            Image.network(
              _coffeeImg!,
              fit: BoxFit.scaleDown,
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked
                        ? Icons.coffee_sharp // '좋아요' 상태에 따라 아이콘 변경
                        : Icons.coffee_outlined,
                    color: _isLiked
                        ? themeColors.color5 // '좋아요' 상태에 따라 아이콘 색상 변경
                        : Colors.grey,
                  ),
                  onPressed: () {
                    _isLiked ? deleteLike() : setLike();
                    setState(() {
                      _isLiked = !_isLiked; // 버튼을 탭할 때마다 '좋아요' 상태 토글
                      _isLiked ? _like += 1 : _like -= 1;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.mode_comment_outlined,
                    color: Colors.grey,
                  ),
                  onPressed:
                      getComment, // 댓글 아이콘을 탭할 때 _showCommentDialog 함수를 호출
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
                      Text("$_like"),
                      const Text("개"),
                      const SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("댓글 "),
                      Text("$_commentCnt"),
                      const Text("개"),
                    ],
                  ),
                  Row(
                    children: [
                      Text("$_title"),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: AnimatedCrossFade(
                          firstChild: Text(
                            _content!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondChild: Text(_content!),
                          crossFadeState: _isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 200),
                        ),
                      ),
                    ],
                  ),
                  if (_content!.length > 50)
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Text(_isExpanded ? "접기" : "더보기"),
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      Text(
                        _regDate.toString().substring(0, 10),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      )
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
