import 'dart:io';

import 'package:fe/constants.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class CommunityWritePage extends StatefulWidget {
  const CommunityWritePage({super.key});

  @override
  _CommunityWritePageState createState() => _CommunityWritePageState();
}

class _CommunityWritePageState extends State<CommunityWritePage> {
  String? _selectedDomain;

  XFile? _image;

  Future getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = pickedFile;
      }
    });
  }

  void getDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('안내메세지'),
          content: _titleController.text == ""
              ? const Text('글의 제목을 입력해주세요.')
              : _contentController.text == ""
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
      formData.fields.add(const MapEntry("domain", "GENERAL"));
      formData.fields.add(MapEntry("title", _titleController.text));
      formData.fields.add(MapEntry("content", _contentController.text));
      formData.files.add(MapEntry(
        "images",
        multipartFile,
      ));
      await apiService.post('/api/board', data: formData);
      Navigator.pushNamed(context, '/pages');
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
      appBar: AppBar(title: const Text('게시글 작성')),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('기술'),
                          value: "Domain.Tech",
                          groupValue: _selectedDomain,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedDomain = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('자유'),
                          value: "자유",
                          groupValue: _selectedDomain,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedDomain = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('질문'),
                          value: "질문",
                          groupValue: _selectedDomain,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedDomain = value;
                            });
                          },
                        ),
                      ),
                    ],
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
                    child: const Icon(Icons.add_a_photo),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      write();
                    },
                    child: const Text('게시글 업로드'),
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
