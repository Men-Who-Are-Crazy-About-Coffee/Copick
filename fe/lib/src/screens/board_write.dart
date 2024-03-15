import 'dart:io';

import 'package:fe/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class BoardWritePage extends StatefulWidget {
  const BoardWritePage({super.key});

  @override
  _BoardWritePageState createState() => _BoardWritePageState();
}

class _BoardWritePageState extends State<BoardWritePage> {
  String? _selectedDomain;

  XFile? image;

  Future getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        image = pickedFile;
      } else {
        print('이미지가 선택되지 않았습니다.');
      }
    });
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _upfilesController = TextEditingController();

  Future<void> _submitPost() async {
    var dio = Dio();
    const String apiUrl = "여기에_API_엔드포인트_URL을_입력하세요";

    try {
      Response response = await dio.post(apiUrl, data: {
        "domain": _selectedDomain,
        "title": _titleController.text,
        "content": _contentController.text,
        "upfiles": [_upfilesController.text], // 리스트 형태로 전송
      });

      if (response.statusCode == 200) {
        // 성공적으로 데이터를 보냈을 때의 처리
        print("게시글이 성공적으로 업로드되었습니다.");
      } else {
        // 에러 처리
        print("게시글 업로드에 실패했습니다.");
      }
    } catch (e) {
      print("에러 발생: $e");
    }
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
                      child: const TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: '내용 입력',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: image == null
                        ? const Text('갤러리에서 이미지를 선택하세요.')
                        : ImageContainer(image: image),
                  ),
                  FloatingActionButton(
                    onPressed: getImage,
                    tooltip: '이미지 선택',
                    child: const Icon(Icons.add_a_photo),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitPost,
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
