import 'dart:async';
import 'package:fe/src/models/screen_params.dart'; // 앱 전역에서 사용되는 화면 매개변수 모델
import 'package:fe/src/yolo/bbox.dart'; // YOLOv8 모델에서 사용되는 경계 상자 모델
import 'package:fe/src/yolo//detector_service.dart'; // 객체 감지 서비스
import 'package:camera/camera.dart'; // 카메라 플러그인
import 'package:flutter/material.dart'; // Flutter의 머티리얼 디자인 위젯

// YOLO 객체 감지 페이지를 위한 StatefulWidget
class VideoPage extends StatefulWidget {
  final CameraDescription camera;

  const VideoPage({Key? key, required this.camera}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

// YoloPage의 상태 관리 클래스
class _VideoPageState extends State<VideoPage> with WidgetsBindingObserver {
  CameraController? _cameraController; // 카메라 컨트롤러
  get _controller => _cameraController; // 초기화되었을 때만 사용됨, null이 아님
  Detector? _detector; // 객체 감지기
  StreamSubscription? _subscription; // 객체 감지 결과 스트림의 구독
  final CameraLensDirection initialCameraLensDirection =
      CameraLensDirection.back; // 초기 카메라 렌즈 방향

  List<String> classes = []; // 감지된 객체의 클래스
  List<List<double>> bboxes = []; // 감지된 객체의 경계 상자 좌표
  List<double> scores = []; // 감지된 객체의 점수

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 앱 생명주기 이벤트를 관찰하기 위해 등록
    _initStateAsync(); // 비동기 초기화 메서드 호출
  }

  // 카메라와 객체 감지기 초기화
  void _initStateAsync() async {
    _initializeCamera(); // 카메라 초기화
    // 새로운 isolate에서 객체 감지기 시작
    Detector.start().then((instance) {
      setState(() {
        _detector = instance;
        // 결과 스트림을 구독하여 상태를 업데이트
        _subscription = instance.resultsStream.stream.listen((values) {
          setState(() {
            classes = values['cls'];
            bboxes = values['box'];
            scores = values['conf'];
          });
        });
      });
    });
  }

  // 카메라 초기화
  void _initializeCamera() async {
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.low,
      enableAudio: false,
    )..initialize().then((_) async {
        await _controller
            .startImageStream(onLatestImageAvailable); // 카메라 이미지 스트림 시작
        setState(() {});
        ScreenParams.previewSize =
            _controller.value.previewSize!; // 화면 매개변수 업데이트
      });
  }

  // 앱 생명주기 상태 변경 시 호출
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        // 앱이 비활성 상태가 되면 리소스 해제
        _cameraController?.stopImageStream();
        _detector?.stop();
        _subscription?.cancel();
        break;
      case AppLifecycleState.resumed:
        // 앱이 다시 활성화되면 초기화
        _initStateAsync();
        break;
      default:
    }
  }

  // 새 카메라 이미지가 사용 가능할 때 호출되는 메서드
  void onLatestImageAvailable(CameraImage cameraImage) async {
    _detector?.processFrame(cameraImage); // 이미지를 객체 감지기로 전달하여 처리
  }

  // 감지된 객체 주위에 경계 상자를 그리는 위젯
  Widget _boundingBoxes() {
    List<Bbox> bboxesWidgets = [];
    for (int i = 0; i < bboxes.length; i++) {
      bboxesWidgets.add(
        Bbox(
          box: bboxes[i],
          name: classes[i],
          score: scores[i],
        ),
      );
    }
    return Stack(children: bboxesWidgets); // 경계 상자 위젯을 스택으로 묶어 반환
  }

  @override
  void dispose() {
    // 앱 종료 시 리소스 해제
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _detector?.stop();
    _subscription?.cancel();
    super.dispose();
  }

  // UI 구성
  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_controller.value.isInitialized) {
      return const SizedBox.shrink(); // 카메라가 초기화되지 않은 경우 빈 위젯 반환
    }
    var aspect = 1 / _controller.value.aspectRatio;
    return Scaffold(
      appBar: AppBar(
        title: const Text('RealTime Test'),
        centerTitle: true,
        backgroundColor: Colors.black38,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () =>
              Navigator.popUntil(context, ModalRoute.withName("/")),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(
            aspectRatio: aspect,
            child: CameraPreview(_controller), // 카메라 미리보기
          ),
          AspectRatio(
            aspectRatio: aspect,
            child: _boundingBoxes(), // 경계 상자 위젯
          ),
        ],
      ),
    );
  }
}
