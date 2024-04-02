import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:fe/constants.dart';
import 'package:fe/src/screens/pages.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  final int? resultIndex;

  const ResultPage({super.key, this.resultIndex});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final ApiService apiService = ApiService();
  final CarouselController _controller = CarouselController();
  int _currentidx = 0;
  bool isLoading = true;
  ThemeColors themeColors = ThemeColors();
  List<String>? sequenceLinks; // 이미지 URL 목록
  int? resultNormal;
  int? resultFlaw;
  String? roastingType;
  String? beanType;
  // recipeList는 이 예제에서는 사용하지 않습니다.

  @override
  void initState() {
    super.initState();
    fetchResultData();
  }

  Future<void> fetchResultData() async {
    setState(() {
      isLoading = true;
    });

    try {
      Response response =
          await apiService.get('/api/result/show/${widget.resultIndex}');
      final data = response.data;
      // JSON 형태의 데이터를 Dart 객체로 변환
      sequenceLinks = List<String>.from(data['sequenceLink']);
      resultNormal = data['resultNormal'];
      resultFlaw = data['resultFlaw'];
      roastingType = data['roastingType'];
      beanType = data['beanType'];
    } catch (e) {
      print("데이터를 받아오는데 실패했습니다: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              themeColors.color5, // 이 부분은 themeColors가 정의되어 있어야 합니다.
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text('결과 확인'),
        ),
        body: isLoading
            ? const Center(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('분석 중...'),
                  CircularProgressIndicator(),
                ],
              ))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 50,
                  ),
                  if (sequenceLinks != null && sequenceLinks!.isNotEmpty)
                    Stack(
                      children: [
                        SizedBox(
                          height: 300,
                          child: CarouselSlider(
                            carouselController: _controller,
                            options: CarouselOptions(
                                enableInfiniteScroll: false,
                                enlargeCenterPage: true,
                                scrollDirection: Axis.horizontal,
                                autoPlay: false,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentidx = index;
                                  });
                                }),
                            items: sequenceLinks!.map((item) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Transform.rotate(
                                      angle: pi / 2,
                                      child: SizedBox(
                                        height: 600,
                                        width: 800,
                                        child: Image.network(
                                          item,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        if (_currentidx > 0)
                          Positioned(
                            left: 10,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios,
                                    size: 30.0),
                                onPressed: () => _controller.previousPage(),
                              ),
                            ),
                          ),
                        if (_currentidx < sequenceLinks!.length - 1)
                          Positioned(
                            right: 10,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios,
                                    size: 30.0),
                                onPressed: () => _controller.nextPage(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  Column(
                    children: [
                      const ListTile(
                        title: Center(
                          child: Text('촬영한 원두의 전체 분석 결과에요.'),
                        ),
                      ),
                      ListTile(
                        title: Center(
                          child: Text('정상 원두 수 : $resultNormal'),
                        ),
                      ),
                      ListTile(
                        title: Center(
                          child: Text('결함 원두 수 : $resultFlaw'),
                        ),
                      ),
                      ListTile(
                        title: Center(
                          child: Text('로스팅 타입 : $roastingType'),
                        ),
                      ),
                      const ListTile(
                        title: Center(
                          child: Text(
                            '결함 원두 데이터는 자동으로 갤러리에 저장됩니다.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // '/page'로 이동하면서 그 이전의 모든 페이지를 스택에서 제거
            Navigator.of(context).pushNamed('/pages');
          },
          tooltip: 'Go to Main Page',
          child: const Icon(Icons.home),
        ),
      ),
    );
  }
}
