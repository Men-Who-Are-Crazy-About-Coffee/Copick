import 'package:dio/dio.dart';
import 'package:fe/constants.dart';
import 'package:fe/src/models/board.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/services/user_provider.dart';
import 'package:fe/src/widgets/board_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentContainer extends StatefulWidget {
  final int index;
  final int boardIndex;
  final String memberImg;
  final String memberNickName;
  final String content;
  final int userId;
  final String regDate;
  final bool isProfile;

  const CommentContainer(
      {super.key,
        required this.index,
        required this.boardIndex,
        required this.userId,
        required this.memberImg,
        required this.memberNickName,
        required this.content,
        required this.regDate,
        this.isProfile= false,
      });

  @override
  State<CommentContainer> createState() => _CommentContainerState();
}

class _CommentContainerState extends State<CommentContainer> {
  String? _memberImg;
  String? _memberNickName;
  String? _content;
  int _userId = 0;
  int? _index;
  int? _boardIndex;
  String _regDate = "";
  late bool _isProfile;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _memberImg = widget.memberImg;
    _memberNickName = widget.memberNickName;
    _index = widget.index;
    _boardIndex = widget.boardIndex;
    _content=widget.content;
    _userId = widget.userId;
    _regDate = widget.regDate;
    _isProfile = widget.isProfile;
  }

  ThemeColors themeColors = ThemeColors();
  TextEditingController commentController = TextEditingController();
  Board _board=Board();

  void deleteComment() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('댓글 삭제'),
          content: const Text('정말 댓글을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('네'),
              onPressed: () async {
                await apiService.delete('/api/comment/$_index');
                Navigator.of(context).pop();
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

  void _showBoardModal() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text(
                '상세 보기',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              content: ChangeNotifierProvider<UserProvider>(
                  create: (context) => UserProvider()..fetchUserData(),
                  child:BoardContainer(
                title: _board.title!,
                coffeeImg: _board.coffeeImg!,
                index: _board.index!,
                memberImg: _board.userProfileImage ?? "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png",
                memberNickName: _board.userNickname!,
                content: _board.content!,
                regDate: _board.regDate!,
                isLiked: _board.liked,
                like: _board.like,
                userId: _board.userId!,
                commentCnt: _board.commentCnt,
              )
          ),
          );
        }
    );
  }

  void getBoard() async {
    try{

    Response response =
    await apiService.get("/api/board/$_boardIndex");
    _board = Board.fromJson(response.data);

    _showBoardModal();
    }catch(e){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('오류'),
            content: const Text('게시글을 불러오는데 실패했습니다.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context); // Counter 인스턴스에 접근
    return GestureDetector(
      onTap: (){
        if(_isProfile){
          getBoard();
        }
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipOval(
              child: Image.network(
                _memberImg ??
                    "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _memberNickName ?? user.user.nickname!,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    (_userId == user.user.index) || (user.user.role == "ADMIN")
                        ? Text(
                      (_regDate)
                          .toString()
                          .substring(0, 10),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ):
                        const Text(""),
                    TextButton(
                      onPressed: () {
                        deleteComment();
                      },
                      child: const Text(
                        "삭제",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _content ?? "",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
