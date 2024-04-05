import 'package:flutter/material.dart';

class RedirectPage extends StatefulWidget {
  const RedirectPage({super.key});

  @override
  State<RedirectPage> createState() => _RedirectPageState();
}

class _RedirectPageState extends State<RedirectPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: Text(
        "로그인 리다이렉트페이지",
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      )),
    );
  }
}
