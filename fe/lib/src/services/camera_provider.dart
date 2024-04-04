import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraProvider with ChangeNotifier {
  CameraDescription? _camera;

  CameraDescription? get camera => _camera;

  void setCamera(CameraDescription camera) {
    _camera = camera;
    notifyListeners(); // 관찰자들에게 변화를 알립니다.
  }
}
