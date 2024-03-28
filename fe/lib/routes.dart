import 'package:camera/camera.dart';
import 'package:fe/src/screens/camera_page.dart';
import 'package:fe/src/screens/community_write_page.dart';
import 'package:fe/src/screens/intro_page.dart';
import 'package:fe/src/screens/login_page.dart';
import 'package:fe/src/screens/pages.dart';
import 'package:fe/src/screens/redirect_page.dart';
import 'package:fe/src/screens/register_page.dart';
import 'package:fe/src/screens/video_page.dart';
import 'package:fe/src/services/camera_provider.dart';
import 'package:provider/provider.dart';

final routes = {
  "/": (context) => const IntroPage(),
  "/login": (context) => const Login(),
  "/register": (context) => const Register(),
  "/auth/login": (context) => const RedirectPage(),
  "/pages": (context) => const Pages(),
  "/community_write": (context) => const CommunityWritePage(),
  "/video": (context) => VideoPage(
      camera: Provider.of<CameraProvider>(context).camera as CameraDescription),
  "/camera": (context) => CameraPage(
      camera: Provider.of<CameraProvider>(context).camera as CameraDescription),
};
