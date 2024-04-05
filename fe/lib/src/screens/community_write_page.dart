import 'dart:io';

import 'package:fe/constants.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CommunityWritePage extends StatefulWidget {
  const CommunityWritePage({super.key});

  @override
  _CommunityWritePageState createState() => _CommunityWritePageState();
}

class _CommunityWritePageState extends State<CommunityWritePage> {
  final String _selectedDomain = "GENERAL";
  String contentText ="";
  XFile? _image;

  Future<void> getImage() async {

    // imageQuality 매개변수 없이 이미지 선택
    if (kIsWeb) {

      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 25,
      );
      if (pickedFile != null) {
        setState(() {
          // 압축된 이미지로 _image 업데이트
          _image = pickedFile;
        });
      }
    } else {
      if(await Permission.photos
          .onDeniedCallback(()=>showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('알림'),
            content: const Text('게시글에는 이미지가 포함되어야합니다.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(false);

                },
              ),
              TextButton(
                child: const Text('설정 열기'),
                onPressed: () {
                  openAppSettings();

                },
              ),
            ],
          );
        },
      ))
          .onPermanentlyDeniedCallback(() {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('알림'),
              content: const Text('게시글에는 이미지가 포함되어야합니다.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop(false);

                  },
                ),
                TextButton(
                  child: const Text('설정 열기'),
                  onPressed: () {
                    openAppSettings();

                  },
                ),
              ],
            );
          },
        );
      })
          .onLimitedCallback(() {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('알림'),
              content: const Text('게시글에는 이미지가 포함되어야합니다.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop(false);

                  },
                ),
                TextButton(
                  child: const Text('설정 열기'),
                  onPressed: () {
                    openAppSettings();

                  },
                ),
              ],
            );
          },
        );
      })
          .request().isGranted) {
        final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );

        if (pickedFile != null) {
          // 파일 확장자 검사
          String extension = pickedFile.path
              .split('.')
              .last
              .toLowerCase();

          if (extension != 'gif') {
            // GIF가 아닌 경우, 이미지 압축
            final compressedFile = await FlutterImageCompress
                .compressAndGetFile(
              pickedFile.path,
              '${pickedFile.path}_compressed.jpg', // 압축된 이미지 저장 경로
              quality: 25, // 압축 품질
            );

            if (compressedFile != null) {
              setState(() {
                // 압축된 이미지로 _image 업데이트
                _image = XFile(compressedFile.path);
              });
            }
          } else {
            setState(() {
              // GIF 이미지인 경우, 원본 이미지로 _image 업데이트
              _image = pickedFile;
            });
          }
        }
      }
    }
  }
  @override
  void initState(){
    super.initState();
    _contentController.addListener(() {
      final String text = _contentController.text;
      _contentController.value = _contentController.value.copyWith(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    _titleController.addListener(() {
      final String text = _titleController.text;
      _titleController.value = _titleController.value.copyWith(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void getDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('안내메세지'),
          content: _titleController.text == ""
              ? const Text('글의 제목을 입력해주세요.')
              : contentText == ""
                  ? const Text("글의 내용을 입력해주세요.")
                  : const Text("이미지를 추가해주세요."),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> write() async {
    ApiService apiService = ApiService();

    try {
      // FormData 객체 생성
      FormData formData = FormData();

      Uint8List fileBytes = await _image!.readAsBytes();

      MultipartFile multipartFile =
          MultipartFile.fromBytes(fileBytes, filename: "uploaded_file.jpg");

      // 텍스트 필드 추가
      formData.fields.add(MapEntry("domain", _selectedDomain));
      formData.fields.add(MapEntry("title", _titleController.text));
      formData.fields.add(MapEntry("content", _contentController.text));
      formData.files.add(MapEntry(
        "images",
        multipartFile,
      ));
      await apiService.post('/api/board', data: formData);
    } catch (e) {
      getDialog();
      return;
    }

    // print(response.data);
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('게시글 작성'),
        backgroundColor: themeColors.color5,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: '제목 입력'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: themeColors.gray,
                        borderRadius: BorderRadius.circular(8),
                        shape: BoxShape.rectangle,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        controller: _contentController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: '내용 입력',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: _image == null
                        ? const Text('갤러리에서 이미지를 선택하세요.')
                        : ImageContainer(image: _image),
                  ),
                  FloatingActionButton(
                    onPressed: getImage,
                    tooltip: '이미지 선택',
                    backgroundColor: themeColors.color5,
                    child: const Icon(Icons.add_a_photo),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false, // 사용자가 다이얼로그 바깥을 탭해도 닫히지 않도록
                        builder: (BuildContext context) {
                          return const Dialog(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 20),
                                  Text("업로드 중..."),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      await write();
                      Navigator.pushNamed(context, '/pages');
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: themeColors.color5),
                    child: const Text(
                      '게시글 업로드',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageContainer extends StatelessWidget {
  final XFile? _image;

  const ImageContainer({
    super.key,
    required XFile? image,
  }) : _image = image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(width: 1, color: Colors.black),
        ),
        width: 50,
        height: 50,
        child: kIsWeb
            ? Image.network(_image!.path)
            : Image.file(File(_image!.path)),
      ),
    );
  }
}
