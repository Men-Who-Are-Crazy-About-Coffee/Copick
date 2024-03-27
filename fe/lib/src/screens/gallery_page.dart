import 'package:fe/constants.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  Map<String, List<String>> groupedItems = {}; // 데이터 저장용 상태 변수

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    ApiService apiService = ApiService();
    try {
      Response response = await apiService.get('/api/result/flaws');
      // API 응답 처리 및 날짜별로 그룹화
      Map<String, List<String>> tempGroupedItems = {};
      for (var item in response.data) {
        String formattedDate =
            DateFormat('yyyy-MM-dd').format(DateTime.parse(item['regDate']));
        tempGroupedItems.putIfAbsent(formattedDate, () => []);
        tempGroupedItems[formattedDate]!.add(item['image']);
      }

      setState(() {
        groupedItems = tempGroupedItems;
      });
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
            width: 200,
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
        title: const Text('결함 원두 분류 사진'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text('각 이미지를 클릭하면 상세하게 볼 수 있어요.'),
              const SizedBox(
                height: 20,
              ),
              const Text('이미지를 꾹 누르면 선택해서 올바르게 검출되지 않은 원두를'),
              const Text('서버에 전송할 수 있어요.'),
              SizedBox(
                width: 500,
                child: Column(
                  children: groupedItems.entries.map(
                    (entry) {
                      return Column(
                        children: [
                          Container(
                            color: themeColors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(entry.key,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Wrap(
                                    children: entry.value.map((imageUrl) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: InkWell(
                                            onTap: () {
                                              detail(imageUrl);
                                            },
                                            child: Image.network(
                                              imageUrl,
                                              width: 70,
                                              height: 70,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const Divider(),
                                ],
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
