import 'dart:ui';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:camera/camera.dart';
import 'package:fe/routes.dart';
import 'package:fe/src/models/screen_params.dart';
import 'package:fe/src/services/camera_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

void main() async {
  CameraDescription? firstCamera;
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras(); // 사용 가능한 카메라 목록을 가져옵니다.#
    firstCamera = cameras.first; // 첫 번째 카메라를 선택합니다.
  } on CameraException catch (e) {
    _logError(e.code, e.description);
  }
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CameraProvider()..setCamera(firstCamera!),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'),
        ],
        scrollBehavior: AppScrollBehavior(),
        builder: (context, child) {
          ScreenParams.screenSize = MediaQuery.of(context).size;
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(
              textScaler: const TextScaler.linear(1.3),
            ),
            child: child!,
          );
        },
        theme: ThemeData(
          fontFamily: "SDchild",
        ),
        routes: routes,
      ),
    ),
  );
}
