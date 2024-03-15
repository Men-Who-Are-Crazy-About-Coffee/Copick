import 'package:flutter/material.dart';
import 'package:fe/src/widgets/bar_chart.dart';
import 'package:fe/src/widgets/pie_chart.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  DateTimeRange? dateRange; // 선택된 날짜 범위를 저장할 변수

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

  // 선택된 날짜 범위를 문자열로 반환하는 함수
  String _getFormattedDateRange() {
    if (dateRange == null) {
      return '날짜를 선택해주세요.';
    } else {
      final DateFormat formatter = DateFormat('yyyy/MM/dd');
      final String start = formatter.format(dateRange!.start);
      final String end = formatter.format(dateRange!.end);
      return '$start - $end';
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // 날짜 선택기 대신 선택된 날짜 범위를 표시
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _getFormattedDateRange(),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const PieChartSample2(),
            const BarChartSample3(),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ChartPage(),
  ));
}
