import 'package:fe/src/screens/intro.dart';
import 'package:flutter/material.dart';
// LoginState 클래스를 정의한 파일

void main() => runApp(
      const MyApp(),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  // final int _selectedIndex = 0; // 현재 선택된 탭 인덱스

  @override
  Widget build(BuildContext context) {
    // Provider를 통해 로그인 상태를 실시간으로 확인

    return const Scaffold(
      body: Center(
        // 현재 선택된 위젯을 표시
        child: Intro(),
      ),
    );
  }
}
