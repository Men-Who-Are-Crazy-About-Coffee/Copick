import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

Future<void> uploadFile() async {
  // 이미지 선택
  final picker = ImagePicker();
  final XFile? file = await picker.pickImage(source: ImageSource.gallery);

  if (file != null) {
    Dio dio = Dio();
    var url = 'https://example.com/upload'; // 실제 업로드할 서버의 URL

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: file.name),
      // "file"은 서버에서 요구하는 키 값이며, 필요에 따라 변경 가능합니다.
      // 추가적으로 다른 데이터를 함께 보내야 할 경우, 여기에 Map 형식으로 추가하면 됩니다.
    });

    try {
      Response response = await dio.post(url, data: formData);
      if (response.statusCode == 200) {
        print("업로드 성공: ${response.data}");
      } else {
        print("서버 오류: ${response.statusCode}");
      }
    } catch (e) {
      print("업로드 실패: $e");
    }
  } else {
    print("파일 선택이 취소되었습니다.");
  }
}

Future<void> sendImage(XFile file) async {
  Dio dio = Dio();
  var url = 'http://192.168.31.45:8080/neighbor/feed'; // 실제 업로드할 서버의 URL

  Uint8List fileBytes = await file.readAsBytes();

  MultipartFile multipartFile =
      MultipartFile.fromBytes(fileBytes, filename: "uploaded_file.jpg");

  FormData formData = FormData.fromMap({
    // "image": MultipartFile.fromBytes(fileBytes, filename: "uploaded_file.jpg"),
    "content": "나는 플러터야",
    // "file"은 서버에서 요구하는 키 값이며, 필요에 따라 변경 가능합니다.
    // 추가적으로 다른 데이터를 함께 보내야 할 경우, 여기에 Map 형식으로 추가하면 됩니다.
  });
  formData.files.add(MapEntry(
    "images",
    multipartFile,
  ));

  try {
    Response response = await dio.post(url, data: formData);
    if (response.statusCode == 200) {
      print("업로드 성공: ${response.data}");
    } else {
      print("서버 오류: ${response.statusCode}");
    }
  } catch (e) {
    print("업로드 실패: $e");
  }
}

// 사진 찍기 화면
class CameraPage extends StatefulWidget {
  final CameraDescription camera;
  final int coffeeTypeValue;

  const CameraPage({super.key, required this.camera, this.coffeeTypeValue = 0});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // 카메라 컨트롤러를 생성합니다.
    _controller = CameraController(
      enableAudio: false,
      widget.camera,
      ResolutionPreset.medium,
    );
    // 컨트롤러를 초기화합니다.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // 위젯의 생명주기가 끝나면 컨트롤러를 해제합니다.
    _controller.dispose();
    super.dispose();
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
            // 사진을 찍습니다.
            final image = await _controller.takePicture();
            // await sendImage(image);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DisplayPictureScreen(imagePath: image.path)),
            );
          } catch (e) {
            const Text("에러");
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
    return Scaffold(
      appBar: AppBar(title: const Text('찍힌 사진 보기')),
      // 이미지를 화면에 꽉 차게 표시합니다.
      body: Image.network(imagePath),
    );
  }
}
