import 'package:fe/src/screens/login_page.dart';
import 'package:flutter/material.dart';

class Intro extends StatefulWidget {
  // final VoidCallback onLoginPressed;
  const Intro({
    super.key,
    // required this.onLoginPressed,
  });

  @override
  State<Intro> createState() => _MainState();
}

class _MainState extends State<Intro> with SingleTickerProviderStateMixin {
  // AnimationController와 Animation 변수를 추가합니다.
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // AnimationController를 초기화합니다.
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // 애니메이션 지속 시간 설정
      vsync: this,
    );

    // 투명도 애니메이션을 설정합니다.
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    // 애니메이션을 시작합니다.
    _controller.forward();
  }

  @override
  void dispose() {
    // Widget이 제거될 때 controller를 정리(clean up)합니다.
    _controller.dispose();
    super.dispose();
  }

  void goLogin() {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Opacity(
              opacity: _animation.value, // 애니메이션 값으로 투명도 설정
              child: SizedBox(
                width: 200,
                height: 200,
                child: Image.asset('assets/images/mainImage.png'), // 이미지 경로
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              '커피 원두, 아직도 눈으로 직접 고르고 계시나요?',
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              '호날두를 통해 빠르고 쉽게 원두를 선별해보세요',
            ),
            const SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              },
              child: const Text(
                '서비스 이용해보기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
