import 'package:fe/src/screens/result_page.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:fe/src/services/api_service.dart';

// 사진 찍기 화면
class CameraPage extends StatefulWidget {
  final CameraDescription camera;
  final int coffeeTypeValue;

  const CameraPage({super.key, required this.camera, this.coffeeTypeValue = 1});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  ApiService apiService = ApiService();
  int? resultIndex; // resultIndex는 int? 타입으로 선언

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );
    _initializeControllerFuture = _controller.initialize();

    try {
      Response response =
          await apiService.get('/api/result/init/${widget.coffeeTypeValue}');
      if (response.data is int) {
        // 서버로부터 받은 데이터가 int 타입인지 확인
        resultIndex = response.data as int;
        print(resultIndex);
      } else {
        print("서버로부터 받은 resultIndex가 int 타입이 아닙니다.");
      }
    } catch (e) {
      print("resultIndex를 받아오는데 실패했습니다: $e");
    }
  }

  Future<String?> sendImage(XFile image) async {
    // 수정: resultIndex를 매개변수로 받지 않음
    if (resultIndex == null) {
      print("resultIndex가 없습니다.");
      return null;
    }

    try {
      String? imageUrl = await apiService.sendImage(image, resultIndex!);
      return imageUrl;
    } catch (e) {
      print("이미지 업로드 실패: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사진 찍기')),
      // 컨트롤러를 초기화하는 동안 로딩 스피너를 표시합니다.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // 초기화가 완료되면 카메라 프리뷰를 표시합니다.
            return Center(child: CameraPreview(_controller));
          } else {
            // 그렇지 않으면 진행 표시기를 표시합니다.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        // 버튼이 눌리면 takePicture() 메서드를 호출합니다.
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            // 이미지 전송 후 반환된 URL을 받습니다.
            String? imageUrl = await sendImage(image);
            if (imageUrl != null) {
              // 반환된 이미지 URL을 DisplayPictureScreen으로 전달합니다.
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                        imagePath: imageUrl, resultIndex: resultIndex)),
              );
            } else {
              print("이미지 업로드 실패 또는 URL을 받지 못함.");
            }
          } catch (e) {
            print("에러: $e");
          }
        },
      ),
    );
  }
}

// 사진을 표시하는 화면
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final int? resultIndex;

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    this.resultIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('찍힌 사진 보기')),
      body: Image.network(imagePath),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ResultPage(resultIndex: resultIndex)), // 올바른 타입으로 전달
          );
        },
      ),
    );
  }
}
