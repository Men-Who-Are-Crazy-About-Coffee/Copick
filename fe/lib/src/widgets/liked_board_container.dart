
import 'package:fe/constants.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'board_container.dart';


class LikedBoardContainer extends StatefulWidget {
  final int index;
  final String? memberImg;
  final String memberNickName;
  final List<dynamic> coffeeImg;
  final String? title;
  final String content;
  final bool isLiked;
  final int like;
  final int userId;
  final int commentCnt;
  final String regDate;
  final bool? isProfile;


  const LikedBoardContainer(
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
        required this.regDate,
        this.isProfile,
      });

  @override
  State<LikedBoardContainer> createState() => _LikedBoardContainerState();
}

class _LikedBoardContainerState extends State<LikedBoardContainer> {
  String? _memberImg;
  String? _memberNickName;
  List<dynamic>? _coffeeImg;
  String? _title;
  String? _content;
  bool _isLiked = false;
  int _like = 0;
  int _commentCnt = 0;
  int _userId = 0;
  int? _index;
  bool _isProfile = false;
  String _regDate = "";
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _memberImg = widget.memberImg;
    _memberNickName = widget.memberNickName;
    _coffeeImg = widget.coffeeImg;
    _title = widget.title;
    _content = widget.content;
    _isLiked = widget.isLiked;
    _like = widget.like;
    _index = widget.index;
    _userId = widget.userId;
    _commentCnt = widget.commentCnt;
    _regDate = widget.regDate;
    _isProfile= widget.isProfile ?? false;
  }

  ThemeColors themeColors = ThemeColors();
  TextEditingController commentController = TextEditingController();

  void setLike() async {
    apiService.post('/api/board/$_index/like');
  }

  void deleteLike() async {
    apiService.delete('/api/board/$_index/like');
  }
  void getBoard() async {
    try{
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
            content:SingleChildScrollView(
                child: BoardContainer(
                  title: _title!,
                  coffeeImg: _coffeeImg!,
                  index: _index!,
                  memberImg: _memberImg ?? "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png",
                  memberNickName: _memberNickName!,
                  content: _content!,
                  regDate: _regDate,
                  isLiked: _isLiked,
                  like: _like,
                  userId: _userId,
                  commentCnt: _commentCnt,
                )
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context); // Counter 인스턴스에 접근
    return GestureDetector(
        onTap: (){
      if(_isProfile){
        getBoard();
      }
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // border: Border.all(width: 1, color: Colors.black),
        ),
        child: Stack(
          fit: StackFit.expand,
    children: [
    Image.network(
              _coffeeImg![0] as String,
              fit: BoxFit.fill,
            ),
    Positioned(
      bottom: 10,
    right: 10,
    child: IconButton(
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
        }
    ),
    ),
    ],
      ),
    ),
    ),
    );
  }
}
