import 'package:flutter/material.dart';
import 'package:fe/constants.dart'; // ThemeColors 정의 포함

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

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // IconButton을 Column과 Text로 묶어 아이콘 아래에 레이블 추가
          _buildTabItem(
            icon: Icons.stacked_bar_chart_sharp,
            label: 'Statistics',
            index: 0,
            themeColors: themeColors,
            isSelected: currentIndex == 0,
            onTap: onItemTapped,
          ),
          _buildTabItem(
            icon: Icons.photo,
            label: 'Gallery',
            index: 1,
            themeColors: themeColors,
            isSelected: currentIndex == 1,
            onTap: onItemTapped,
          ),
          const SizedBox(width: 48), // FloatingActionButton을 위한 공간
          _buildTabItem(
            icon: Icons.people_alt,
            label: 'Community',
            index: 3,
            themeColors: themeColors,
            isSelected: currentIndex == 2,
            onTap: onItemTapped,
          ),
          _buildTabItem(
            icon: Icons.account_circle_rounded,
            label: 'Settings',
            index: 4,
            themeColors: themeColors,
            isSelected: currentIndex == 3,
            onTap: onItemTapped,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
    required ThemeColors themeColors,
    required bool isSelected,
    required Function(int) onTap,
  }) {
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: isSelected ? themeColors.color5 : Colors.grey),
          Text(label,
              style: TextStyle(
                  color: isSelected ? themeColors.color5 : Colors.grey)),
        ],
      ),
    );
  }
}
