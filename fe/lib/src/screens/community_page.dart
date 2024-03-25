import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/services/board_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  ApiService apiService = ApiService();
  List<Widget> boardWidgets = [];

  final storage = const FlutterSecureStorage();
  Future<void> isLogin() async {
    String? accessToken = await storage.read(key: "ACCESS_TOKEN");
    if (accessToken == null) Navigator.pushNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    isLogin();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BoardProvider>(
      create: (_) => BoardProvider()..started(),
      child: Consumer<BoardProvider>(builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('자유 게시판'),
            automaticallyImplyLeading: false,
          ),
          body: Center(
            child: SizedBox(
              width: 500,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/community_write'),
                        icon: const Icon(Icons.post_add),
                      ),
                    ],
                  ),
                  if (value.items.isEmpty)
                    const Column(
                      children: [
                        SizedBox(
                          height: 200,
                        ),
                        Text(
                          "게시글이 없습니다.",
                          style: TextStyle(fontSize: 40),
                        )
                      ],
                    ),
                  Expanded(
                    child: NotificationListener<ScrollUpdateNotification>(
                      onNotification: (ScrollUpdateNotification notification) {
                        value.listner(notification);
                        return false;
                      },
                      child: ListView.builder(
                        itemCount: value.items.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
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
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
