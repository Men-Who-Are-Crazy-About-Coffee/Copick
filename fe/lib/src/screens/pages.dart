import 'package:camera/camera.dart';
import 'package:fe/constants.dart';
import 'package:fe/src/screens/camera_page.dart';
import 'package:fe/src/services/camera_provider.dart';
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
  String _selectedCoffeeType = '아라비카';
  String _selectedMediaType = '사진';

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

  void addWidgets(CameraDescription? camera) {
    widgetOptions = [
      const StatPage(),
      const GalleryPage(),
      const CommunityPage(),
      const ProfilePage()
    ];
  }

  void selectBean() {
    showDialog(
      context: context,
      builder: (
        __,
      ) {
        return AlertDialog(
          title: const Text('검출 시작 설정'),
          content: StatefulBuilder(builder: (__, StateSetter setDialogState) {
            return SizedBox(
              height: 200,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('사진'),
                    leading: Radio<String>(
                      value: '사진',
                      groupValue: _selectedMediaType,
                      onChanged: (String? value) {
                        setDialogState(() => _selectedMediaType = value!);
                        setState(() {});
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('동영상'),
                    leading: Radio<String>(
                      value: '동영상',
                      groupValue: _selectedMediaType,
                      onChanged: (String? value) {
                        setDialogState(() => _selectedMediaType = value!);
                        setState(() {});
                      },
                    ),
                  ),
                  if (_selectedMediaType == '사진')
                    DropdownButton<String>(
                      value: _selectedCoffeeType,
                      items: <String>['아라비카', '로부스타', '리베리카']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() => _selectedCoffeeType = newValue!);
                        setState(() {});
                      },
                    ),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedMediaType == '사진') {
                        final coffeeTypeValue =
                            getCoffeeTypeValue(_selectedCoffeeType);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CameraPage(
                                    camera: Provider.of<CameraProvider>(context,
                                            listen: false)
                                        .camera as CameraDescription,
                                    coffeeTypeValue:
                                        coffeeTypeValue))); // 숫자 값을 CameraPage에 전달
                      } else if (_selectedMediaType == '동영상') {
                        Navigator.pushNamed(context, '/video');
                      }
                    },
                    child: const Text('시작'),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cameraProvider = Provider.of<CameraProvider>(context);
    final camera = cameraProvider.camera;
    addWidgets(camera);

    ThemeColors themeColors = ThemeColors();
    // 로그인되지 않았을 경우 로그인 페이지를 리스트에 추가
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => {
        kIsWeb
            ? const Text('ndkdkdk')
            : showDialog(
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
                        onPressed: () => {
                          SystemNavigator.pop(),
                        }, // 앱 종료
                        child: const Text('예'),
                      ),
                    ],
                  );
                },
              )
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
                backgroundColor: themeColors.color5,
                child: const Icon(Icons.camera, size: 40),
                onPressed: () {
                  selectBean();
                }
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const SelectionPage()),
                // ),
                ),
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
