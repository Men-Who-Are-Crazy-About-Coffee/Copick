import 'package:dio/dio.dart';
import 'package:fe/constants.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:flutter/material.dart';

class BoardContainer extends StatefulWidget {
  final int index;
  final String memberImg;
  final String memberNickName;
  final List<dynamic> coffeeImg;
  final String title;
  final String content;
  final bool isLiked;
  final int like;

  const BoardContainer({
    super.key,
    required this.index,
    required this.memberImg,
    required this.memberNickName,
    required this.coffeeImg,
    required this.title,
    required this.content,
    required this.isLiked,
    required this.like,
  });

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
  int? _like;
  int? _index;
  bool _isExpanded = false;
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
  }

  ThemeColors themeColors = ThemeColors();
  final List<String> _comments = [
    '첫 번째 댓글입니다!',
    '두 번째 댓글입니다!',
    // 더 많은 댓글이 있을 수 있습니다.
  ];

  void _showModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        TextEditingController commentController = TextEditingController();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_comments[index]),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: '댓글 추가...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      setState(() {
                        _comments.add(commentController.text);
                        commentController.clear();
                      });
                      // 모달을 닫고 싶지 않으면 아래 줄을 주석 처리하세요.
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void getComment() async {
    _showModalBottomSheet();
    print(_index);
    // Response response = await apiService.get("/api/comment/board/$_index");
    // _comments = response.data['list'];
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
                Text("$_memberNickName")
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
                    setState(() {
                      _isLiked = !_isLiked; // 버튼을 탭할 때마다 '좋아요' 상태 토글
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
                    )
                ],
              ),
            )
          ],
        ), //전체 컬럼
      ),
    );
  }
}
