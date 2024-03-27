import 'package:fe/constants.dart';
import 'package:flutter/material.dart';

// BottomNavbar.dart 파일 내용 수정
class BottomNavbar extends StatelessWidget {
  final int currentIndex; // 현재 선택된 인덱스
  final Function(int) onItemTapped; // 탭 변경 시 호출될 콜백

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    return Material(
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onItemTapped, // 외부에서 제공된 콜백을 사용
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.stacked_bar_chart_sharp),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: currentIndex == 1
                ? Image.asset(
                    'assets/images/coffeeBean2.png',
                    width: 24,
                    height: 24,
                  )
                : Image.asset(
                    'assets/images/coffeeBean1.png',
                    width: 24,
                    height: 24,
                  ),
            label: 'Gallery',
          ),
          const BottomNavigationBarItem(
            icon: SizedBox(width: 50),
            label: '', // 레이블 없음
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Community',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Settings',
          ),
        ],
        selectedItemColor: themeColors.color5,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
