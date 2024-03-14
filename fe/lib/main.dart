import 'package:camera/camera.dart';
import 'package:fe/src/camera_provider.dart';
import 'package:fe/src/screens/board_list.dart';
import 'package:fe/src/screens/camera.dart';
import 'package:fe/src/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 사용 가능한 카메라 목록을 가져옵니다.
  final cameras = await availableCameras();
  // 첫 번째 카메라를 선택합니다.
  final firstCamera = cameras.first;

  return runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => CameraProvider()..setCamera(firstCamera)),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: const FirstPage(),
      ),
    ),
  );
}

// 첫 번째 페이지 위젯
class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraProvider = Provider.of<CameraProvider>(context);
    final camera = cameraProvider.camera;
    return Scaffold(
      appBar: AppBar(
        title: const Text('메인'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: const Text('게시판 이동'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BoardListPage()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('프로필 이동'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyProfile()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('카메라페이지 이동'),
              onPressed: () {
                if (camera != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TakePictureScreen(camera: camera)),
                  );
                } else {
                  print("선택가능한 카메라 없음");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
