import 'package:fe/src/screens/community_write_page.dart';
import 'package:fe/src/screens/intro_page.dart';
import 'package:fe/src/screens/login_page.dart';
import 'package:fe/src/screens/pages.dart';
import 'package:fe/src/screens/register_page.dart';

final routes = {
  "/": (context) => const IntroPage(),
  "/login": (context) => const Login(),
  "/register": (context) => const Register(),
  "/pages": (context) => const Pages(),
  "/community_write": (context) => const CommunityWritePage(),
};
