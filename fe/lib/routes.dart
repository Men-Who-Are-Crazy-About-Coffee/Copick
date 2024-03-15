import 'package:fe/main.dart';
import 'package:fe/src/camera_provider.dart';
import 'package:fe/src/screens/board_write.dart';
import 'package:fe/src/screens/camera.dart';
import 'package:fe/src/screens/intro.dart';
import 'package:fe/src/screens/profile_page.dart';
import 'package:fe/src/screens/board_list.dart';
import 'package:provider/provider.dart';

final routes = {
  "/": (context) => const Intro(),
  "/board_list": (context) => BoardListPage(),
  "/board_write": (context) => const BoardWritePage(),
  "/profile": (context) => MyProfile(),
  "/camera": (context) {
    final cameraProvider = Provider.of<CameraProvider>(context);
    final camera = cameraProvider.camera;
    if (camera != null) {
      return TakePictureScreen(camera: camera);
    } else {
      return const FirstPage();
    }
  }
};
