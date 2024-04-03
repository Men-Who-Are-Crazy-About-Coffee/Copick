import 'package:fe/constants.dart';
import 'package:fe/src/screens/community_page.dart';
import 'package:fe/src/screens/gallery_page.dart';
import 'package:fe/src/screens/stat_page.dart';
import 'package:fe/src/screens/profile_page.dart';
import 'package:fe/src/services/user_provider.dart';
import 'package:fe/src/widgets/bottomnavbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  late PageController _pageController;
  int _selectedIndex = 0; // 현재 선택된 탭 인덱스
  late List<Widget> widgetOptions;

  int getCoffeeTypeValue(String coffeeType) {
    switch (coffeeType) {
      case '아라비카':
        return 1;
      case '로부스타':
        return 2;
      case '리베리카':
        return 3;
      default:
        return 0; // 기본값 혹은 알 수 없는 값
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    isLogin();
  }

  final storage = const FlutterSecureStorage();
  Future<void> isLogin() async {
    String? accessToekn = await storage.read(key: "ACCESS_TOKEN");
    if (accessToekn == null) Navigator.pushNamed(context, '/');
  }

  void addWidgets() {
    widgetOptions = [
      const StatPage(),
      const GalleryPage(),
      const CommunityPage(),
      const ProfilePage()
    ];
  }

  @override
  Widget build(BuildContext context) {
    addWidgets();

    ThemeColors themeColors = ThemeColors();
    // 로그인되지 않았을 경우 로그인 페이지를 리스트에 추가
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Future.microtask(() => {
              if (kIsWeb)
                {const Text('ndkdkdk')}
              else
                {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('알림'),
                        content: const Text('앱을 종료할까요?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(false), // 앱을 종료하지 않음
                            child: const Text('아니요'),
                          ),
                          TextButton(
                            onPressed: () {
                              SystemNavigator.pop(); // 앱 종료
                            },
                            child: const Text('예'),
                          ),
                        ],
                      );
                    },
                  )
                }
            });
      },
      child: ChangeNotifierProvider(
        create: (context) => UserProvider()..fetchUserData(),
        child: Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
                // 페이지 변경 시 스크롤 물리 상태 업데이트
              });
            },
            children: widgetOptions,
          ),
          floatingActionButton: SizedBox(
            width: 80,
            height: 80,
            child: FloatingActionButton(
                shape: const StadiumBorder(),
                backgroundColor: themeColors.color5,
                child: const Icon(Icons.camera, size: 40),
                onPressed: () async {
                  Navigator.pushNamed(context, '/video');
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('경고'),
                        content: const Text('카메라를 찾을 수 없습니다.'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('확인'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomNavbar(
            currentIndex: _selectedIndex,
            onItemTapped: onItemTapped,
          ),
        ),
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
    // 카메라 페이지를 스킵하기 위한 로직
  }
}
