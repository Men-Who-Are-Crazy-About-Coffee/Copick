import 'package:flutter/widgets.dart';

import 'indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartSample2 extends StatefulWidget {
  const PieChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final List<int> values = [80, 20]; // 차트의 값들을 리스트로 관리

    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 1,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Indicator(
                color: const Color(0xffD4A373),
                text: '정상 원두 : ${values[0]}', // 값 동적으로 표시,
                isSquare: true,
              ),
              const SizedBox(
                width: 8, // Padding 대신 SizedBox의 width 사용
              ),
              Indicator(
                color: const Color(0xffD9D9D9),
                text: '결함 원두 : ${values[1]}', // 값 동적으로 표시
                isSquare: true,
              ),
            ],
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;
      return PieChartSectionData(
        color: i == 0 ? const Color(0xffD4A373) : const Color(0xffD9D9D9),
        value: i == 0 ? 80 : 20,
        title: '', // 값을 표시하지 않음
        showTitle: false, // 타이틀 표시하지 않기
        radius: radius,
      );
    });
  }
}
