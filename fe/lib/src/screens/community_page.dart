import 'package:dio/dio.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/services/board_provider.dart';
import 'package:fe/src/widgets/board_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

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

  ApiService apiService = ApiService();
  List<Widget> boardWidgets = [];

  final storage = const FlutterSecureStorage();
  Future<void> isLogin() async {
    String? accessToekn = await storage.read(key: "ACCESS_TOKEN");
    if (accessToekn == null) Navigator.pushNamed(context, '/login');
  }

  Future<List<dynamic>> getCommunityList(int page) async {
    Response response = await apiService
        .get('/api/board/search?domain=GENERAL&size=2&page=$page');
    print(response.data['list']);
    return response.data['list'];
  }

  @override
  void initState() {
    // TODO: implement initState
    // getCommunityList(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BoardProvider>(
      create: (_) => BoardProvider()..started(),
      child: Consumer<BoardProvider>(builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('자유 게시판')),
          body: NotificationListener<ScrollUpdateNotification>(
            onNotification: (ScrollUpdateNotification notification) {
              value.listner(notification);
              return false;
            },
            child: ListView.builder(
                itemCount: value.items.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: SizedBox(
                      width: 500,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 20),
                          IconButton(
                            onPressed: () => Navigator.pushNamed(
                                context, '/community_write'),
                            icon: const Icon(Icons.post_add),
                          ),
                          value.items[index],
                          if (value.isMore &&
                              value.currentIndex == index + 1) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: CircularProgressIndicator(
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
          ),
        );
      }),
    );
  }
}
