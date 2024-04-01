import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/services/board_provider.dart';
import 'package:fe/src/services/profile_content_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class MyContentPage extends StatefulWidget {
  final ProfileContentType profileContentType;


  const MyContentPage({super.key, required this.profileContentType});


  @override
  State<MyContentPage> createState() => _MyContentPageState();
}

class _MyContentPageState extends State<MyContentPage> {
  ApiService apiService = ApiService();
  List<Widget> boardWidgets = [];
  late ProfileContentType _profileContentType;

  final storage = const FlutterSecureStorage();
  Future<void> isLogin() async {
    String? accessToken = await storage.read(key: "ACCESS_TOKEN");
    if (accessToken == null) Navigator.pushNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    _profileContentType= widget.profileContentType;
    isLogin();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileContentProvider>(
      create: (_) => ProfileContentProvider()..started(_profileContentType),
      child: Consumer<ProfileContentProvider>(builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('내 게시글 보기'),
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
                        icon: const Icon(Icons.filter_list),
                      ),
                    ],
                  ),
                  if (value.isLoading)
                    const CircularProgressIndicator()
                  else if (value.items.isEmpty && !value.isLoading)
                    const Column(
                      children: [
                        SizedBox(
                          height: 200,
                        ),
                        Text(
                          "내가 쓴 게시글이 없습니다.",
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
