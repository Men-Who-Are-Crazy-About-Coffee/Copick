import 'package:camera/camera.dart';
import 'package:fe/constants.dart';
import 'package:fe/src/services/camera_provider.dart';
import 'package:fe/src/screens/camera_page.dart';
import 'package:fe/src/screens/community_page.dart';
import 'package:fe/src/screens/gallery_page.dart';
import 'package:fe/src/screens/home_page.dart';
import 'package:fe/src/screens/profile_page.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/services/user_provider.dart';
import 'package:fe/src/widgets/bottomnavbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  int _selectedIndex = 0; // 현재 선택된 탭 인덱스
  late List<Widget> widgetOptions;
  @override
  void initState() {
    super.initState();
    // if (로그인되지 않았다면) {
    //   widgetOptions.add(Login());
    // }
  }

  void addWidgets(CameraDescription? camera) {
    widgetOptions = [
      const HomePage(),
      const GalleryPage(),
      CameraPage(camera: camera!),
      CommunityPage(),
      const ProfilePage()
    ];
  }

  final storage = const FlutterSecureStorage();
  Future<void> getToken() async {
    // String? token1 = await storage.read(key: 'REFRESH_TOKEN');
    // String? token2 = await storage.read(key: 'ACCESS_TOKEN');
    // print("token1 : $token1");
    // print("token2 : $token2");
  }

  @override
  Widget build(BuildContext context) {
    final cameraProvider = Provider.of<CameraProvider>(context);
    final camera = cameraProvider.camera;
    addWidgets(camera);

    ThemeColors themeColors = ThemeColors();
    // 로그인되지 않았을 경우 로그인 페이지를 리스트에 추가
    return ChangeNotifierProvider(
      create: (context) => UserProvider()..fetchUserData(),
      child: Scaffold(
        body: widgetOptions.elementAt(_selectedIndex),
        floatingActionButton: SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            backgroundColor: themeColors.color5,
            child: const Icon(Icons.camera, size: 40),
            onPressed: () => onItemTapped(2),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavbar(
          currentIndex: _selectedIndex,
          onItemTapped: onItemTapped,
        ),
      ),
    );
  }

  void onItemTapped(int index) {
    setState(
      () {
        _selectedIndex = index;
      },
    );
  }
}
