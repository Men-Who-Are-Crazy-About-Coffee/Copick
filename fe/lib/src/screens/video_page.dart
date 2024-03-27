import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fe/src/services/camera_provider.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class VideoPage extends StatefulWidget {
  final CameraDescription camera;

  const VideoPage({super.key, required this.camera});

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late CameraController? _controller;
  late WebSocketChannel? _channel;
  ui.Image? _image; // ui.Image 객체를 저장할 변수

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      enableAudio: false,
      widget.camera,
      ResolutionPreset.medium,
    );
    _controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      startImageStream();
    });

    _channel = WebSocketChannel.connect(
      Uri.parse('wss://ai.copick.duckdns.org/ws/python/video'),
    );

    _channel!.stream.listen((dynamic message) {
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
    _image = await completer.future;
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  void startImageStream() async {
    Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!_controller!.value.isInitialized) {
        print("Controller is not initialized");
        return;
      }
      try {
        final image = await _controller!.takePicture();
        final bytes = await image.readAsBytes();
        _channel!.sink.add(bytes);
      } catch (e) {
        print("사진 캡처 또는 전송 실패: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Camera WebSocket Streaming - No Preview'),
        ),
        body: Center(
          child: _image == null
              ? const Text('Sending Images...')
              : RawImage(image: _image), // ui.Image 객체를 사용하여 이미지 표시
        ));
  }
}
