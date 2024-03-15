import 'package:fe/constants.dart';
import 'package:fe/src/screens/home.dart';
import 'package:fe/src/widgets/bottomnavbar.dart';
import 'package:flutter/material.dart';

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  int _selectedIndex = 0; // 현재 선택된 탭 인덱스

  @override
  Widget build(BuildContext context) {
    const List<Widget> widgetOptions = [
      Home(),
    ];
    // 로그인되지 않았을 경우 로그인 페이지를 리스트에 추가
    return Scaffold(
      body: widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          backgroundColor: AppColors.color5,
          child: const Icon(Icons.camera, size: 40),
          onPressed: () {},
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(
      () {
        _selectedIndex = index;
      },
    );
  }
}
