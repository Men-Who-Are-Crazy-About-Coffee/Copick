// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:fe/constants.dart';
import 'package:fe/src/screens/pages.dart';
import 'package:fe/src/screens/register_page.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/widgets/rounded_button.dart';
import 'package:fe/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  late String nickname = "hoseong";
  Future<void> login(String id, String password) async {
    ApiService apiService = ApiService();
    Response<dynamic> response =
        await apiService.post('/api/auth/login', data: {
      "id": id,
      "password": password,
    });
    print(response.data);

    // if (!mounted) return; // 여기에서 mounted를 확인

    // } catch (e) {
    //   // 오류 처리
    //   print(e);
    //   if (!mounted) return; // 필요하다면 여기에서도 mounted를 확인할 수 있습니다.
    //   // 오류 메시지 표시 등의 UI 관련 작업을 수행
    // }
    // Navigator.pushNamed(context, '/pages');
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();

    void navigateToSignUp() {
      Navigator.pushNamed(context, '/register');
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
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
                          const SizedBox(
                            height: 30,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 30,
                          ),
                          Card(
                            elevation: 18,
                            clipBehavior: Clip.antiAlias,
                            child: Ink.image(
                              image:
                                  const AssetImage('assets/images/kakao.png'),
                              fit: BoxFit.cover, // 이미지 채우기 방식 지정
                              width: 300,
                              height: 60,
                              child: InkWell(
                                onTap: () {},

                                // InkWell이 꽉 찬 영역에 반응하도록 Container 등으로 감싸거나 크기를 지정
                                child: const SizedBox(
                                  width: 500, // InkWell의 크기를 지정
                                  height: 60,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
