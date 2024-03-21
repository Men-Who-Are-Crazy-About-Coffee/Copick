import 'package:dio/dio.dart';
import 'package:fe/constants.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/services/delete_storage.dart';
import 'package:fe/src/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ApiService apiService = ApiService();
  DeleteStorage deleteStorage = DeleteStorage();
  String defaultImg =
      "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png";

  void logout() {
    deleteStorage.deleteAll();
    Navigator.pushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    var user = Provider.of<UserProvider>(context); // Counter 인스턴스에 접근

    void unRegister() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('회원 탈퇴'),
            content: const Text('정말 회원 탈퇴하시겠습니까?'),
            actions: <Widget>[
              TextButton(
                child: const Text('네'),
                onPressed: () async {
                  await apiService.delete("/api/member/${user.user.index}");
                  DeleteStorage deleteStorage = DeleteStorage();
                  deleteStorage.deleteAll();
                  Navigator.pushNamed(context, '/login');
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

    const storage = FlutterSecureStorage();
    Future<void> isLogin() async {
      String? accessToekn = await storage.read(key: "ACCESS_TOKEN");
    }

    @override
    void initState() {
      super.initState();
      isLogin();
    }

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: "Back",
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text("프로필")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                width: 375,
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                      width: 375,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: const BoxDecoration(
                                  shape: BoxShape
                                      .circle, // 여기에 circle을 추가하여 더 명확한 원형을 강조할 수도 있습니다.
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    defaultImg,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, top: 10, bottom: 20, right: 40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              user.user.id!,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text(user.user.nickname!),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            // print("버튼pressd");
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: themeColors.black,
                            side: BorderSide(
                                color: themeColors.color5,
                                width: 2), // 테두리 색상과 두께
                            fixedSize: const Size(300, 30),
                          ),
                          child: const Text('프로필 편집하기'),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            print('TextButton이 눌렸습니다.');
                          },
                          child: const Text("내 게시글 보기"),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.grey, // 색상을 원하는 대로 지정할 수 있습니다.
                      height: 20, // 구분선의 높이를 조절할 수도 있습니다.
                      thickness: 1, // 구분선의 두께를 조절할 수도 있습니다.
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            print('TextButton이 눌렸습니다.');
                          },
                          child: const Text("내 댓글 보기"),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.grey, // 색상을 원하는 대로 지정할 수 있습니다.
                      height: 20, // 구분선의 높이를 조절할 수도 있습니다.
                      thickness: 1, // 구분선의 두께를 조절할 수도 있습니다.
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            print('TextButton이 눌렸습니다.');
                          },
                          child: const Text("내가 좋아요 한 글 보기"),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.grey, // 색상을 원하는 대로 지정할 수 있습니다.
                      height: 20, // 구분선의 높이를 조절할 수도 있습니다.
                      thickness: 1, // 구분선의 두께를 조절할 수도 있습니다.
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            logout();
                          },
                          child: const Text("로그아웃"),
                        ),
                        const SizedBox(
                          width: 200,
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.grey, // 색상을 원하는 대로 지정할 수 있습니다.
                      height: 20, // 구분선의 높이를 조절할 수도 있습니다.
                      thickness: 1, // 구분선의 두께를 조절할 수도 있습니다.
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            unRegister();
                          },
                          child: const Text("회원탈퇴하기"),
                        ),
                        const SizedBox(
                          width: 200,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
