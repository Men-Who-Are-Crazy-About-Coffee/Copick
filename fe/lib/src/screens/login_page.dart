// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:fe/constants.dart';
import 'package:fe/src/widgets/rounded_button.dart';
import 'package:fe/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  final storage = const FlutterSecureStorage();

  Future<void> login(String id, String password) async {
    if (id.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('알림'),
            content: const Text('아이디와 비밀번호를 모두 입력해야 해요.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
      return; // Exit the function if ID or password is empty
    }
    Dio dio = Dio();
    try {
      String baseUrl = dotenv.env['BASE_URL']!;
      Response response = await dio.post('$baseUrl/api/auth/login', data: {
        "id": id,
        "password": password,
      });
      Map<String, dynamic> responseMap = response.data;
      await storage.write(
          key: "ACCESS_TOKEN", value: responseMap["accessToken"]);
      await storage.write(
          key: "REFRESH_TOKEN", value: responseMap["refreshToken"]);
      Navigator.pushNamed(context, '/pages');
    } on DioException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('알림'),
            content: const Text('아이디, 비밀번호가 일치하지 않거나 없는 회원이에요.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // 대화상자 닫기
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();

    void navigateToSignUp() {
      Navigator.pushNamed(context, '/register');
    }

    return Center(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 115,
              ),
              const Center(
                child: Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
              ),
              Form(
                child: Theme(
                  data: ThemeData(
                      primaryColor: Colors.grey,
                      inputDecorationTheme: const InputDecorationTheme(
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 15.0))),
                  child: Container(
                      width: 500,
                      padding: const EdgeInsets.all(40.0),
                      // 키보드가 올라와서 만약 스크린 영역을 차지하는 경우 스크롤이 되도록
                      // SingleChildScrollView으로 감싸 줌
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            InputField(
                              controller: idController,
                              label: 'Id',
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            InputField(
                              label: 'password',
                              controller: pwController,
                            ),
                            const SizedBox(
                              height: 40.0,
                            ),
                            RoundedButton(
                              maintext: '로그인',
                              bgcolor: themeColors.color1,
                              onPressed: () {
                                login(idController.text, pwController.text);
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            RoundedButton(
                              maintext: '회원가입',
                              bgcolor: themeColors.color2,
                              onPressed: navigateToSignUp,
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
