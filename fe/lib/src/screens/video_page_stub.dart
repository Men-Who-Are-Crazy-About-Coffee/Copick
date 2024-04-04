// lib/screens/video_page_stub.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class VideoPage extends StatelessWidget {
  final CameraDescription camera;

  const VideoPage({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Platform not supported')),
    );
  }
}
