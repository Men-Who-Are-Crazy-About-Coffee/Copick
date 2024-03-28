import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fe/constants.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:fe/src/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:fe/src/widgets/bar_chart.dart';
import 'package:fe/src/widgets/pie_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum LoadingState {
  loading,
  completed,
  empty,
}

class StatPage extends StatefulWidget {
  const StatPage({super.key});

  @override
  _StatPageState createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  LoadingState loadingState = LoadingState.loading;
  ThemeColors themeColors = ThemeColors();
  DateTimeRange? dateRange; // 선택된 날짜 범위를 저장할 변수
  double normal = 0;
  double flaw = 0;
  double other = 0;
  String formattedDateRange = '';

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
        updateFormattedDateRange();
      });
    }
  }

  void updateFormattedDateRange() {
    if (dateRange != null) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String start = formatter.format(dateRange!.start);
      final String end = formatter.format(dateRange!.end);
      formattedDateRange = '$start - $end'; // 상태 업데이트
      sendData(start, end, context); // 날짜가 설정될 때만 sendData 호출
    } else {
      DateTime now = DateTime.now();
      DateTime oneWeekAgo = now.subtract(const Duration(days: 7));
      String formattedToday = DateFormat('yyyy-MM-dd').format(now);
      String formattedOneWeekAgo = DateFormat('yyyy-MM-dd').format(oneWeekAgo);
      formattedDateRange = '$formattedOneWeekAgo ~ $formattedToday';
    }
  }

  final storage = const FlutterSecureStorage();
  Future<void> isLogin() async {
    String? accessToekn = await storage.read(key: "ACCESS_TOKEN");
    if (accessToekn == null) Navigator.pushNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    isLogin();
    loadingState = LoadingState.loading;
    DateTime now = DateTime.now();
    DateTime oneWeekAgo = now.subtract(const Duration(days: 7));
    dateRange = DateTimeRange(start: oneWeekAgo, end: now);
    updateFormattedDateRange();
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

      if (responseMap.isNotEmpty && responseMap["myNormalPercent"] != null) {
        setState(() {
          normal = responseMap["myNormalPercent"];
          flaw = responseMap["myFlawPercent"];
          other = responseMap["totalNormalPercent"];
          loadingState = LoadingState.completed; // 데이터 로딩 완료
        });
      } else {
        setState(() {
          loadingState = LoadingState.empty; // 데이터 없음
        });
      }
      // 정상적인 응답 처리
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        setState(() {
          loadingState = LoadingState.empty;
        });
      } else {
        // 다른 오류 처리
      }
    }
  }

  // 선택된 날짜 범위를 문자열로 반환하는 함수
  String _getFormattedDateRange() {
    if (dateRange == null) {
      DateTime now = DateTime.now();
      DateTime oneWeekAgo = now.subtract(const Duration(days: 7));
      String formattedToday = DateFormat('yyyy-MM-dd').format(now);
      String formattedOneWeekAgo = DateFormat('yyyy-MM-dd').format(oneWeekAgo);
      sendData(formattedOneWeekAgo, formattedToday, context);
      return '$formattedOneWeekAgo ~ $formattedToday';
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
        automaticallyImplyLeading: false,
        backgroundColor: themeColors.color5,
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
              const SizedBox(
                height: 30,
              ),
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
                  formattedDateRange,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              normal != 0 && flaw != 0
                  ? PieChartSample2(normal: normal, flaw: flaw)
                  : loadingState == LoadingState.loading
                      ? const CircularProgressIndicator() // 로딩 중 인디케이터 표시
                      : const Column(
                          children: [
                            SizedBox(
                              height: 50,
                            ),
                            Text('해당 구간에는 데이터가 없어요.'),
                          ],
                        ),
              normal != 0 && flaw != 0
                  ? BarChartSample3(
                      normal: normal,
                      other: other,
                    )
                  : const Center(
                      child: SizedBox(
                        height: 30,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
