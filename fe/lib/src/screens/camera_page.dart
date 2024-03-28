import 'dart:typed_data';

import 'package:fe/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

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
  String? resultIndex;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    // 카메라 컨트롤러 생성 및 초기화
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();

    // 서버로부터 resultIndex 받기
    try {
      Response response = await apiService
          .get('/api/result/init/${widget.coffeeTypeValue.toString()}');
      resultIndex = response.data;
    } catch (e) {
      print("resultIndex를 받아오는데 실패했습니다: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String?> sendImage(XFile file) async {
    Dio dio = Dio();
    var url = 'https://ai.copick.duckdns.org/api/python/analyze';
    Uint8List fileBytes = await file.readAsBytes();
    MultipartFile multipartFile =
        MultipartFile.fromBytes(fileBytes, filename: file.name);

    FormData formData = FormData.fromMap({
      "resultIndex": resultIndex,
      "file": multipartFile,
    });

    try {
      Response response = await dio.post(url, data: formData);
      if (response.statusCode == 200) {
        String imageUrl = response.data;
        return imageUrl;
      } else {
        print("서버 오류: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("업로드 실패: $e");
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
                    builder: (context) =>
                        DisplayPictureScreen(imagePath: imageUrl)),
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

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // 네트워크 이미지를 표시합니다.
    return Scaffold(
      appBar: AppBar(title: const Text('찍힌 사진 보기')),
      body: Image.network(imagePath),
    );
  }
}
