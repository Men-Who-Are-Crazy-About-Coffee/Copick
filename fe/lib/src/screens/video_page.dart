import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(VideoPage());
}

class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  CameraController? controller;
  WebSocketChannel? channel;
  ui.Image? image; // ui.Image 객체를 저장할 변수

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras![0], ResolutionPreset.medium);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      startImageStream();
    });

    channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8000/ws/python/video'),
    );

    channel!.stream.listen((dynamic message) {
      updateImage(message);
    });
  }

  Future<void> updateImage(Uint8List imageData) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageData, (ui.Image img) {
      if (!completer.isCompleted) {
        completer.complete(img);
      }
    });
    image = await completer.future;
    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    channel?.sink.close();
    super.dispose();
  }

  void startImageStream() async {
    Timer.periodic(Duration(milliseconds: 150), (timer) async {
      if (!controller!.value.isInitialized) {
        print("Controller is not initialized");
        return;
      }
      try {
        final image = await controller!.takePicture();
        final bytes = await image.readAsBytes();
        channel!.sink.add(bytes);
      } catch (e) {
        print("사진 캡처 또는 전송 실패: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Camera WebSocket Streaming - No Preview'),
        ),
        body: Center(
          child: image == null
              ? Text('Sending Images...')
              : RawImage(image: image), // ui.Image 객체를 사용하여 이미지 표시
        ),
      ),
    );
  }
}
