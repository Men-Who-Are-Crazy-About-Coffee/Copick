import 'package:flutter/material.dart';
import 'src/screens/chart_page.dart'; // 차트 페이지 파일 임포트

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chart App',
      initialRoute: '/', // 초기 라우트 설정
      routes: {
        '/': (context) => MainPage(), // 기본 라우트로 메인 페이지 설정
        '/chart': (context) => ChartPage(), // '/chart' 라우트로 차트 페이지 설정
      },
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메인 페이지'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/chart'); // 라우터를 통해 차트 페이지로 이동
          },
          child: Text('차트 페이지로 이동'),
        ),
      ),
    );
  }
}
