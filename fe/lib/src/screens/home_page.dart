import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:fe/src/widgets/bar_chart.dart';
import 'package:fe/src/widgets/pie_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTimeRange? dateRange; // 선택된 날짜 범위를 저장할 변수
  double normal = 0;
  double flaw = 0;
  double other = 0;

  // 날짜 범위 선택기를 표시하는 함수
  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      initialDateRange: dateRange,
    );

    if (newDateRange != null) {
      setState(() {
        dateRange = newDateRange;
      });
    }
  }

  Future<void> sendData(
      String startDate, String endDate, BuildContext context) async {
    ApiService apiService = ApiService();
    try {
      Response response = await apiService.post(
        '/api/result/analyze',
        data: {
          "startDate": startDate,
          "endDate": endDate,
        },
      );
      Map<String, dynamic> responseMap = response.data;
      setState(() {
        normal = responseMap["myNormalPercent"];
        flaw = responseMap["myFlawPercent"];
      });
      // 정상적인 응답 처리
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // 404 오류 처리
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('알림'),
              content: const Text('해당 구간에는 데이터가 없어요.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop(); // 대화상자 닫기
                  },
                ),
              ],
            );
          },
        );
      } else {
        // 다른 오류 처리
      }
    } catch (e) {
      // DioException 이외의 오류 처리
    }
  }

  // 선택된 날짜 범위를 문자열로 반환하는 함수
  String _getFormattedDateRange() {
    if (dateRange == null) {
      return '날짜를 선택해주세요.';
    } else {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String start = formatter.format(dateRange!.start);
      final String end = formatter.format(dateRange!.end);
      sendData(start, end, context);
      return '$start - $end';
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('로스팅 통계'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _pickDateRange(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Text(
                '현재까지 ${user.user.nickname}님이 촬영한 원두 분석 통계에요.',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _getFormattedDateRange(),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              normal != 0 && flaw != 0
                  ? PieChartSample2(
                      normal: normal,
                      flaw: flaw,
                    )
                  : const SizedBox(
                      height: 80,
                    ),
              BarChartSample3(
                normal: normal,
                other: other,
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
