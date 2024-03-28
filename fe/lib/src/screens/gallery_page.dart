import 'dart:convert';

import 'package:fe/constants.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

enum LoadingState {
  loading, // 데이터 로딩 중
  completed, // 데이터 로딩 완료
  empty, // 데이터 없음
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  Map<String, List<Map<String, dynamic>>> groupedItems = {};
  final ThemeColors _themeColors = ThemeColors(); // 데이터 저장용 상태 변수
  List<String> selectedImages = [];
  List<dynamic> errorList = [];
  bool isSelectMode = false;
  LoadingState loadingState = LoadingState.loading;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    ApiService apiService = ApiService();
    loadingState = LoadingState.loading;
    try {
      Response response = await apiService.get('/api/result/flaws');

      Map<String, List<Map<String, dynamic>>> tempGroupedItems = {};
      for (var item in response.data) {
        String formattedDate =
            DateFormat('yyyy-MM-dd').format(DateTime.parse(item['regDate']));
        tempGroupedItems.putIfAbsent(formattedDate, () => []);
        tempGroupedItems[formattedDate]!.add({
          'image': item['image'],
          'isChecked': false,
          'flawIndex': item['flawIndex'],
        });
      }
      if (tempGroupedItems.isEmpty) {
        setState(() {
          loadingState = LoadingState.empty;
        });
      } else {
        setState(() {
          groupedItems = tempGroupedItems;
          loadingState = LoadingState.completed;
        });
      }
    } on DioException catch (e) {
      print(e);
      loadingState = LoadingState.empty;
    }
  }

  void enableSelectMode() {
    setState(() {
      isSelectMode = true;
    });
  }

  void toggleCheckbox(String date, int index, bool? value) {
    var image = groupedItems[date]![index];
    setState(() {
      image['isChecked'] = value!;
      if (value) {
        errorList.add(image['flawIndex']);
        // 체크 시 errorList에 추가
      } else {
        errorList.removeWhere((element) => element == image['flawIndex']);
      }
    });
  }

  void saveSelectedImages() {
    selectedImages.clear();
    groupedItems.forEach((date, images) {
      for (var image in images) {
        if (image['isChecked']) {
          selectedImages.add(image['image']);
        }
      }
    });

    // 선택된 이미지 리스트를 활용하는 로직 (예: 서버에 전송)
    print('선택된 이미지들: $selectedImages');
  }

  Future<void> sendError() async {
    ApiService apiService = ApiService();
    String jsonData = jsonEncode(errorList);

    try {
      Response response = await apiService.post(
        '/api/result/flaws/update',
        data: jsonData,
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('알림'),
            content: const Text('선택된 데이터가 서버로 전송되었어요.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  setState(() {
                    isSelectMode = false;
                    errorList.clear();
                    Reload();
                  });
                  Navigator.of(context).pop(); // 대화상자 닫기
                },
              ),
            ],
          );
        },
      );
    } on DioException catch (e) {
      print(e);
    }
  }

  void Reload() {
    getData();
  }

  Future<void> detail(String imageurl) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '자세히 보기',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          content: Image.network(
            imageurl,
            fit: BoxFit.cover,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColors.color5,
        automaticallyImplyLeading: false,
        actions: [
          if (isSelectMode) ...[
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: sendError,
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  isSelectMode = false;
                  errorList.clear();
                });
              },
            ),
          ],
        ],
        title: const Text('결함 원두 분류 사진'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              if (!isSelectMode) ...[
                const SizedBox(height: 50),
                const Text('각 이미지를 클릭하면 상세하게 볼 수 있어요.'),
                const SizedBox(height: 20),
                const Text('이미지를 꾹 누르면 선택해서 올바르게 검출되지 않은 원두를'),
                const Text('서버에 전송할 수 있어요.'),
                const SizedBox(height: 20),
              ],
              if (isSelectMode) ...[
                const SizedBox(height: 50),
                const Text('전송할 이미지를 선택해주세요.'),
                const SizedBox(height: 20),
                const Text('전송한 이미지는 갤러리에서 삭제됩니다.'),
                const SizedBox(height: 40),
              ],
              if (loadingState == LoadingState.loading)
                const CircularProgressIndicator(),
              if (loadingState == LoadingState.empty)
                const Text("현재 갤러리에 업로드된 이미지가 없어요..."),
              if (loadingState == LoadingState.completed)
                ...groupedItems.entries
                    .map((entry) => buildDateSection(entry.key, entry.value)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDateSection(String date, List<Map<String, dynamic>> images) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                date,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index) {
                var image = images[index];
                return GestureDetector(
                  onTap: () {
                    if (isSelectMode) {
                      toggleCheckbox(date, index, !image['isChecked']);
                    } else {
                      detail(image['image']);
                    }
                  },
                  onLongPress: () {
                    enableSelectMode();
                    toggleCheckbox(date, index, true);
                  },
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 50,
                      maxHeight: 50,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            image['image'],
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null)
                                return child; // 이미지 로딩 완료
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null, // 로딩 진행 상태 표시
                                ),
                              );
                            },
                          ),
                          if (isSelectMode)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Transform.scale(
                                scale: 1.25,
                                child: Checkbox(
                                  side: const BorderSide(
                                      color: Colors.white, width: 2),
                                  shape: const CircleBorder(),
                                  activeColor: _themeColors.color5,
                                  value: image['isChecked'],
                                  onChanged: (bool? value) {
                                    toggleCheckbox(date, index, value);
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
