import 'package:fe/constants.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/services/profile_content_provider.dart';
import 'package:fe/src/services/user_provider.dart';
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
  late ProfileContentType _profileContentType;

  final storage = const FlutterSecureStorage();
  Future<void> isLogin() async {
    String? accessToken = await storage.read(key: "ACCESS_TOKEN");
    if (accessToken == null) Navigator.pushNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    if (!context.mounted) return;
    _profileContentType = widget.profileContentType;
    isLogin();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileContentProvider>(
            create: (_) => ProfileContentProvider()
              ..started(_profileContentType)),
      ],
      child: Consumer<ProfileContentProvider>(builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("내 ${_profileContentType.type} 보기"),
            centerTitle: true,
            backgroundColor: themeColors.color5,
          ),
          body: Center(
            child: SizedBox(
              width: 600,
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // IconButton(
                      //   onPressed: () =>
                      //       Navigator.pushNamed(context, '/community_write'),
                      //   icon: const Icon(Icons.filter_list),
                      // ),
                    ],
                  ),
                  if (value.isLoading)
                    const CircularProgressIndicator()
                  else if (value.items.isEmpty && !value.isLoading)
                    Column(
                      children: [
                        const SizedBox(
                          height: 200,
                        ),
                        Text(
                          "내가 쓴 ${_profileContentType.type}이 없습니다.",
                          style: const TextStyle(fontSize: 40),
                        )
                      ],
                    ),
                  if (_profileContentType.view == "List")
                    Expanded(
                      child: NotificationListener<ScrollUpdateNotification>(
                        onNotification:
                            (ScrollUpdateNotification notification) {
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
                  if (_profileContentType.view == "Grid")
                    Expanded(
                      child: NotificationListener<ScrollUpdateNotification>(
                        onNotification:
                            (ScrollUpdateNotification notification) {
                          value.listner(notification);
                          return false;
                        },
                        child: GridView.builder(
                          itemCount: value.items.length,
                          scrollDirection: Axis.vertical,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 10),
                          itemBuilder: (context, index) {
                            return Expanded(
                              child: value.items[index],
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
