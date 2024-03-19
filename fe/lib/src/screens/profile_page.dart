import 'package:dio/dio.dart';
import 'package:fe/constants.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String memberImg =
      "https://cdn.ceomagazine.co.kr/news/photo/201802/1714_4609_1642.jpg";

  late Map<String, dynamic> userInfo;
  String id = "";
  String role = "";
  String index = "";
  String nickname = "";
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    Response response = await apiService.get('/api/member/my');
    setState(() {
      userInfo = response.data;
      id = userInfo['id'];
      nickname = userInfo['nickname'];
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();

    void getDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('편집'),
            content: const Text('상태 편집 기능이 구현될 예정입니다.'),
            actions: <Widget>[
              TextButton(
                child: const Text('닫기'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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
        child: Column(
          children: [
            const Row(children: []),
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              width: 400,
              child: Column(
                children: [
                  SizedBox(
                    height: 150,
                    width: 400,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Center(
                            // Center 위젯을 추가하여 이미지를 중앙에 배치합니다.
                            child: Container(
                              height: 120,
                              width: 120,
                              decoration: const BoxDecoration(
                                shape: BoxShape
                                    .circle, // 여기에 circle을 추가하여 더 명확한 원형을 강조할 수도 있습니다.
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  memberImg,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
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
                                            id,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(nickname),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          getDialog();
                                        },
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
