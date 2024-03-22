import 'package:camera/camera.dart';
import 'package:fe/routes.dart';
import 'package:fe/src/services/camera_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 사용 가능한 카메라 목록을 가져옵니다.
  final cameras = await availableCameras();
  // 첫 번째 카메라를 선택합니다.
  final firstCamera = cameras.first;
  await dotenv.load(fileName: ".env");

  return runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => CameraProvider()..setCamera(firstCamera)),
      ],
      child: MaterialApp(
        routes: routes,
      ),
    ),
  );
}
