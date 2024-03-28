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
  Map<String, List<Map<String, dynamic>>> groupedItems = {}; // 데이터 저장용 상태 변수
  List<String> selectedImages = [];
  List<dynamic> errorList = [];
  bool isSelectMode = false;
  LoadingState loadingState = LoadingState.loading;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void Reload() {
    getData();
  }

  Future<void> getData() async {
    ApiService apiService = ApiService();
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
        errorList.remove(image['flawIndex']);
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
                  isSelectMode = false;
                  Reload();
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
            height: 250,
            width: 100,
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
            Row(
              children: [
                IconButton(
                  icon: const Text('전송'),
                  onPressed: () {
                    sendError();
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                IconButton(
                  icon: const Text('취소'),
                  onPressed: () {
                    setState(() {
                      isSelectMode = false;
                    });
                  },
                ),
              ],
            )
          ],
        ],
        title: const Text('결함 원두 분류 사진'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              if (!isSelectMode) ...[
                const SizedBox(
                  height: 50,
                ),
                const Text('각 이미지를 클릭하면 상세하게 볼 수 있어요.'),
                const SizedBox(
                  height: 20,
                ),
                const Text('이미지를 꾹 누르면 선택해서 올바르게 검출되지 않은 원두를'),
                const Text('서버에 전송할 수 있어요.'),
                const SizedBox(
                  height: 20,
                ),
              ],
              if (isSelectMode) ...[
                const SizedBox(
                  height: 50,
                ),
                const Text('전송할 이미지를 선택해주세요.'),
                const SizedBox(
                  height: 20,
                ),
                const Text('전송한 이미지는 갤러리에서 삭제됩니다.'),
                const SizedBox(
                  height: 40,
                ),
              ],
              SizedBox(
                width: 600,
                child: Column(
                  children: loadingState == LoadingState.loading
                      ? [
                          const SizedBox(
                            height: 100,
                          ),
                          const CircularProgressIndicator()
                        ]
                      : loadingState == LoadingState.empty
                          ? [
                              const SizedBox(height: 100),
                              const Text(
                                '현재 갤러리에 업로드된 이미지가 없어요...',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                '원두를 촬영하고 사진을 등록해보는건 어떨까요?',
                                style: TextStyle(fontSize: 18),
                              ),
                            ]
                          : groupedItems.entries.map(
                              (entry) {
                                return Column(
                                  children: [
                                    Container(
                                      color: themeColors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0),
                                                child: Text(
                                                  entry.key,
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 1.0),
                                                child: Wrap(
                                                  spacing: 8.0,
                                                  runSpacing: 8.0,
                                                  alignment:
                                                      WrapAlignment.center,
                                                  children: List.generate(
                                                      entry.value.length,
                                                      (index) {
                                                    var imageurl = entry
                                                        .value[index]['image'];
                                                    var isChecked =
                                                        entry.value[index]
                                                            ['isChecked'];
                                                    return Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        InkWell(
                                                          onLongPress: () {
                                                            // 이미지를 길게 누르면 선택 모드 활성화
                                                            setState(() {
                                                              isSelectMode =
                                                                  true;
                                                            });
                                                          },
                                                          onTap: () {
                                                            if (!isSelectMode) {
                                                              // 선택 모드가 아닐 때만 상세보기 함수 호출
                                                              detail(imageurl);
                                                            } else {
                                                              // 선택 모드일 때는 이미지 탭으로 체크박스 토글
                                                              toggleCheckbox(
                                                                  entry.key,
                                                                  index,
                                                                  !isChecked);
                                                            }
                                                          },
                                                          child: Stack(
                                                            children: [
                                                              SizedBox(
                                                                width: 88,
                                                                height: 88,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0), // 이미지에 둥근 모서리 추가 (선택적)
                                                                  child: Image
                                                                      .network(
                                                                    imageurl,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              if (isSelectMode) // 선택 모드가 활성화되었을 때만 체크박스 표시
                                                                Positioned(
                                                                  top: 0,
                                                                  right: 0,
                                                                  child:
                                                                      Checkbox(
                                                                    activeColor:
                                                                        themeColors
                                                                            .color5,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15),
                                                                    ),
                                                                    value:
                                                                        isChecked,
                                                                    onChanged:
                                                                        (bool?
                                                                            value) {
                                                                      toggleCheckbox(
                                                                          entry
                                                                              .key,
                                                                          index,
                                                                          value);
                                                                    },
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              const Divider(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    )
                                  ],
                                );
                              },
                            ).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
