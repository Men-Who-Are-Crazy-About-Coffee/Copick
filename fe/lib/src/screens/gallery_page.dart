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

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColors.color5,
        automaticallyImplyLeading: false,
        title: const Text('지난 원두 분류 사진'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
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
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(imageUrl,
                                          width: 70, height: 70),
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
                        height: 16,
                      )
                    ],
                  );
                },
              ).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
