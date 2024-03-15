import 'package:fe/constants.dart';
import 'package:fe/src/widgets/button1.dart';
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
  Gender? _selectedGender = Gender.male;

  void _handleRadioValueChange(Gender? value) {
    setState(() {
      _selectedGender = value;
    });
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
                          InputField(
                            label: '나이',
                            controller: ageController,
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('성별'),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                children: <Widget>[
                                  Flexible(
                                    child: ListTile(
                                      title: const Text('남자'),
                                      leading: Radio<Gender>(
                                        value: Gender.male,
                                        groupValue: _selectedGender,
                                        onChanged: _handleRadioValueChange,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: ListTile(
                                      title: const Text('여자'),
                                      leading: Radio<Gender>(
                                        value: Gender.female,
                                        groupValue: _selectedGender,
                                        onChanged: _handleRadioValueChange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Text(
                          //     'Selected gender: ${_selectedGender.toString().split('.').last}'),
                          const SizedBox(
                            height: 15,
                          ),
                          Button1(
                            maintext: '회원가입',
                            bgcolor: themeColors.color2,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Button1(
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
