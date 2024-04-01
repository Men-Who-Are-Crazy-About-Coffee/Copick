import 'package:fe/constants.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/widgets/rounded_button.dart';
import 'package:fe/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

enum Gender { male, female }

class _RegisterState extends State<Register> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  void join() {
    if (idController.text == "" ||
        pwController.text == "" ||
        nicknameController.text == "") {
      getDialog();
      return;
    }
    ApiService apiService = ApiService();
    apiService.post('/api/auth/register', data: {
      "id": idController.text,
      "password": pwController.text,
      "nickname": nicknameController.text,
    });
    Navigator.pushNamed(context, '/login');
  }

  void getDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('안내메세지'),
          content: idController.text == ""
              ? const Text('아이디를 입력해주세요.')
              : pwController.text == ""
                  ? const Text("비밀번호를 입력해주세요.")
                  : const Text("닉네임을 입력해주세요."),
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

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
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
                '회원가입',
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
                            label: 'Id',
                            controller: idController,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          InputField(
                            label: 'password',
                            controller: pwController,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          InputField(
                            label: '닉네임',
                            controller: nicknameController,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          RoundedButton(
                            maintext: '회원가입',
                            bgcolor: themeColors.color2,
                            onPressed: () {
                              join();
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          RoundedButton(
                            maintext: '돌아가기',
                            bgcolor: themeColors.color2,
                            onPressed: () => Navigator.pop(context),
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
