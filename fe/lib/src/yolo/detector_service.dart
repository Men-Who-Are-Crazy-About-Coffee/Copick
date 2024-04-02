import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:fe/src/yolo/image_utils.dart';
import 'package:fe/src/yolo/nms.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

enum _Codes { init, busy, ready, detect, result }

class _Command {
  const _Command(this.code, {this.args});

  final _Codes code;
  final List<Object>? args;
}

class Detector {
  static const String _modelPath = 'assets/models/best_float32.tflite';
  static const String _labelPath = 'assets/models/label.txt';

  Detector._(this._isolate, this._interpreter, this._labels);

  final Isolate _isolate;
  late final Interpreter _interpreter;
  late final List<String> _labels;

  late final SendPort _sendPort;

  bool _isReady = false;

  final StreamController<Map<String, dynamic>> resultsStream =
      StreamController<Map<String, dynamic>>();

  static Future<Detector> start() async {
    final ReceivePort receivePort = ReceivePort();
    final Isolate isolate =
        await Isolate.spawn(_DetectorServer._run, receivePort.sendPort);

    final Detector result = Detector._(
      isolate,
      await _loadModel(),
      await _loadLabels(),
    );
    receivePort.listen((message) {
      result._handleCommand(message as _Command);
    });
    return result;
  }

  static Future<Interpreter> _loadModel() async {
    final interpreterOptions = InterpreterOptions();

    // Use XNNPACK Delegate
    if (Platform.isAndroid) {
      interpreterOptions.addDelegate(XNNPackDelegate());
      // gpu
      // interpreterOptions.addDelegate(GpuDelegateV2());
    }

    return Interpreter.fromAsset(
      _modelPath,
      options: interpreterOptions..threads = 4,
    );
  }

  static Future<List<String>> _loadLabels() async {
    return (await rootBundle.loadString(_labelPath)).split('\n');
  }

  void processFrame(CameraImage cameraImage) {
    if (_isReady) {
      _sendPort.send(_Command(_Codes.detect, args: [cameraImage]));
    }
  }

  void _handleCommand(_Command command) {
    switch (command.code) {
      case _Codes.init:
        _sendPort = command.args?[0] as SendPort;
        RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
        _sendPort.send(_Command(_Codes.init,
            args: [rootIsolateToken, _interpreter.address, _labels]));
      case _Codes.ready:
        _isReady = true;
      case _Codes.busy:
        _isReady = false;
      case _Codes.result:
        _isReady = true;
        resultsStream.add(command.args?[0] as Map<String, dynamic>);
      default:
        debugPrint('Detector unrecognized command: ${command.code}');
    }
  }

  void stop() {
    _isolate.kill();
  }
}

class _DetectorServer {
  int mlModelInputSize = 640; // 이미지 사이즈, 설정 없으면 기본 사용
  Interpreter? _interpreter;
  List<String>? _labels;

  _DetectorServer(this._sendPort);

  final SendPort _sendPort;

  static void _run(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    final _DetectorServer server = _DetectorServer(sendPort);
    receivePort.listen((message) async {
      final _Command command = message as _Command;
      await server._handleCommand(command);
    });
    sendPort.send(_Command(_Codes.init, args: [receivePort.sendPort]));
  }

  Future<void> _handleCommand(_Command command) async {
    switch (command.code) {
      case _Codes.init:
        RootIsolateToken rootIsolateToken =
            command.args?[0] as RootIsolateToken;
        BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
        _interpreter = Interpreter.fromAddress(command.args?[1] as int);
        // [1,224, 224, 3] 이면 224 가져와서 설정
        mlModelInputSize =
            _interpreter?.getInputTensors().first.shape[1] ?? 640;
        _labels = command.args?[2] as List<String>;
        _sendPort.send(const _Command(_Codes.ready));
      case _Codes.detect:
        _sendPort.send(const _Command(_Codes.busy));
        _convertCameraImage(command.args?[0] as CameraImage);
      default:
        debugPrint('_DetectorService unrecognized command ${command.code}');
    }
  }

  void _convertCameraImage(CameraImage cameraImage) {
    var preConversionTime = DateTime.now().millisecondsSinceEpoch;

    convertCameraImageToImage(cameraImage).then((image) {
      if (image != null) {
        if (Platform.isAndroid) {
          image = image_lib.copyRotate(image, angle: 90);
        }

        final results = analyseImage(image, preConversionTime);
        _sendPort.send(_Command(_Codes.result, args: [results]));
      }
    });
  }

  Map<String, dynamic> analyseImage(
      image_lib.Image? image, int preConversionTime) {
    var conversionElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preConversionTime;
    var preProcessStart = DateTime.now().millisecondsSinceEpoch;

    final imageInput = image_lib.copyResize(image!,
        width: mlModelInputSize, height: mlModelInputSize);

    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.rNormalized, pixel.gNormalized, pixel.bNormalized];
        },
      ),
    );

    var preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;
    var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;

    final output = _runInference(imageMatrix);

    List<List<double>> rawOutput =
        (output.first as List).first as List<List<double>>;

    List<int> idx = [];
    List<String> cls = [];
    List<List<double>> box = [];
    List<double> conf = [];
    // 라벨 수 적용
    final numOfLabels = _labels?.length ?? 0;
    final count = numOfLabels + 4;
    (idx, box, conf) =
        nms(rawOutput, count, confidenceThreshold: 0.75, iouThreshold: 0.4);

    if (idx.isNotEmpty) {
      cls = idx.map((e) => _labels![e]).toList();
    }

    // for (var i = 0; i < cls.length; i++) {
    //   debugPrint('cls item: ${cls[i]}');
    //   debugPrint('box item: ${box[i]}');
    //   debugPrint('conf item: ${conf[i]}');

    //   if (cls[i] == 'bad' && conf[i] < 0.8) {
    //     cls[i] = 'good';
    //     debugPrint('!!!change item: ${cls[i]}');
    //   }
    // }

    var inferenceElapsedTime =
        DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;
    var totalElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preConversionTime;

    return {
      "cls": cls,
      "box": box,
      "conf": conf,
      "stats": <String, String>{
        'Conversion time:': conversionElapsedTime.toString(),
        'Pre-processing time:': preProcessElapsedTime.toString(),
        'Inference time:': inferenceElapsedTime.toString(),
        'Total prediction time:': totalElapsedTime.toString(),
        'Frame': '${image.width} X ${image.height}',
      },
    };
  }

  List<Object> _runInference(List<List<List<num>>> imageMatrix) {
    // Set input tensor [1, 640, 640, 3] [1, 224, 244, 3]
    final input = [imageMatrix];
    // korail_lens [1, 55, 8400] [1, 55, 1029] yolov8n [1, 84, 8400]
    // final outputs =
    //     List<num>.filled(1 * count * 8400, 0).reshape([1, count, 8400]);
    final numOut = _interpreter?.getOutputTensors().first.shape[0] ?? 1;
    final numOut1 = _interpreter?.getOutputTensors().first.shape[1] ?? 1;
    final numOut2 = _interpreter?.getOutputTensors().first.shape[2] ?? 1;
    // debugPrint('input ${_interpreter?.getInputTensors().first.shape}');
    // debugPrint('output ${_interpreter?.getOutputTensors().first.shape}');
    final outputs = List<num>.filled(numOut * numOut1 * numOut2, 0)
        .reshape([numOut, numOut1, numOut2]);
    var map = <int, Object>{};
    map[0] = outputs;
    _interpreter!.runForMultipleInputs([input], map);
    return map.values.toList();
  }
}
