import 'package:dio/dio.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/widgets/board_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final ScrollController _scrollController = ScrollController();
  bool isLiked = true;
  int like = 1;
  int page = 0;
  bool _isLoading = false;
  ApiService apiService = ApiService();
  List<Widget> boardWidgets = [];

  final storage = const FlutterSecureStorage();
  Future<void> isLogin() async {
    String? accessToekn = await storage.read(key: "ACCESS_TOKEN");
    if (accessToekn == null) Navigator.pushNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    isLogin();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!_isLoading) {
      setState(() {
        page++;
        _isLoading = true;
      });

      try {
        // 여기에 dio 요청을 보내는 코드를 작성합니다.
        Response response = await apiService
            .get('/api/board/search?domain=GENERAL&size=2&page=$page');
        var boards = response.data;
        for (var board in boards) {
          String userImg = "";
          board['userProfileImage'] == null
              ? userImg =
                  "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png"
              : userImg = board['userProfileImage'];

          boardWidgets.add(
            BoardContainer(
              coffeeImg: board['images'], // 이 부분은 실제 데이터에 맞게 조정하세요
              memberNickName: board['userNickname'],
              memberImg: userImg,
              comment: board['content'],
              like: like,
              isLiked: isLiked,
            ),
          );
        }

        // 데이터를 처리하고 상태를 업데이트하는 등의 작업을 수행합니다.
      } catch (e) {}

      setState(() {
        _isLoading = false;
      });
    }
    return;
  }

  Future<List<dynamic>> getCommunityList(int page) async {
    Response response = await apiService
        .get('/api/board/search?domain=GENERAL&size=2&page=$page');
    print("boardwidget: $boardWidgets");
    return response.data['list'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('자유 게시판')),
      body: SingleChildScrollView(
        controller: _scrollController,
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
                  future: getCommunityList(page), // 비동기 데이터 로드
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // 데이터 로딩 중
                    } else if (snapshot.hasError) {
                      return Text("에러가 발생했습니다: ${snapshot.error}");
                    } else {
                      // 데이터 로드 성공
                      var boards = snapshot.data!; // 'boardList' 데이터 활용
                      for (var board in boards) {
                        String userImg = "";
                        board['userProfileImage'] == null
                            ? userImg =
                                "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png"
                            : userImg = board['userProfileImage'];

                        boardWidgets.add(
                          BoardContainer(
                            coffeeImg:
                                board['images'], // 이 부분은 실제 데이터에 맞게 조정하세요
                            memberNickName: board['userNickname'],
                            memberImg: userImg,
                            comment: board['content'],
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
