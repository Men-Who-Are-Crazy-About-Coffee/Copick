import 'package:flutter/material.dart';

import 'package:fe/src/screens/video_page.dart';
import 'package:fe/src/screens/camera_page.dart';

import 'package:camera/camera.dart';
import 'package:fe/src/services/camera_provider.dart';
import 'package:provider/provider.dart';

class SelectionPage extends StatefulWidget {
  const SelectionPage({super.key});

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

int getCoffeeTypeValue(String coffeeType) {
  switch (coffeeType) {
    case '아라비카':
      return 1;
    case '로부스타':
      return 2;
    case '리베리카':
      return 3;
    default:
      return 0; // 기본값 혹은 알 수 없는 값
  }
}

class _SelectionPageState extends State<SelectionPage> {
  String _selectedCoffeeType = '아라비카';
  String _selectedMediaType = '사진';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('검출 시작 설정'),
      ),
      body: Column(
        children: [
          // '사진' 선택 시에만 드롭다운 메뉴 표시

          ListTile(
            title: const Text('사진'),
            leading: Radio<String>(
              value: '사진',
              groupValue: _selectedMediaType,
              onChanged: (String? value) {
                setState(() {
                  _selectedMediaType = value!;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('동영상'),
            leading: Radio<String>(
              value: '동영상',
              groupValue: _selectedMediaType,
              onChanged: (String? value) {
                setState(() {
                  _selectedMediaType = value!;
                });
              },
            ),
          ),
          if (_selectedMediaType == '사진')
            DropdownButton<String>(
              value: _selectedCoffeeType,
              items: <String>['아라비카', '로부스타', '리베리카']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCoffeeType = newValue!;
                });
              },
            ),
          ElevatedButton(
            onPressed: () {
              if (_selectedMediaType == '사진') {
                final coffeeTypeValue = getCoffeeTypeValue(_selectedCoffeeType);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CameraPage(
                            camera: Provider.of<CameraProvider>(context,
                                    listen: false)
                                .camera as CameraDescription,
                            coffeeTypeValue:
                                coffeeTypeValue))); // 숫자 값을 CameraPage에 전달
              } else if (_selectedMediaType == '동영상') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoPage(
                            camera: Provider.of<CameraProvider>(context,
                                    listen: false)
                                .camera as CameraDescription)));
              }
            },
            child: Text('시작'),
          ),
        ],
      ),
    );
  }
}
