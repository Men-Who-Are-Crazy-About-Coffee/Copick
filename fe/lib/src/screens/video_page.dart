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
  late CameraController _controller;
  late WebSocketChannel _channel;
  ui.Image? _image; // ui.Image 객체를 저장할 변수
  Timer? _timer; // Timer 객체를 저장할 변수
  bool _firstResponseReceived = false; // 첫 번째 응답을 받았는지 추적하는 플래그

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      enableAudio: false,
      widget.camera,
      ResolutionPreset.medium,
    );
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      // 초기 이미지 캡처 및 전송
      captureAndSendImage();
    });

    _channel = WebSocketChannel.connect(
      Uri.parse('wss://ai.copick.duckdns.org/ws/python/video'),
    );

    _channel.stream.listen((dynamic message) {
      if (!_firstResponseReceived) {
        _firstResponseReceived = true; // 첫 번째 응답 수신
        startImageStream(); // 응답 수신 후 이미지 스트리밍 시작
      }
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
    _controller.dispose();
    _channel.sink.close();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> captureAndSendImage() async {
    if (!_controller.value.isInitialized) {
      print("Controller is not initialized");
      return;
    }
    try {
      final image = await _controller.takePicture();
      final bytes = await image.readAsBytes();
      _channel.sink.add(bytes);
    } catch (e) {
      print("첫 번째 사진 캡처 또는 전송 실패: $e");
    }
  }

  void startImageStream() {
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!_controller.value.isInitialized || !_firstResponseReceived) {
        return;
      }
      try {
        final image = await _controller.takePicture();
        final bytes = await image.readAsBytes();
        _channel.sink.add(bytes);
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
            : RawImage(image: _image),
      ),
    );
  }
}
