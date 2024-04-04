import 'dart:async';

import 'package:flutter/widgets.dart';

import 'indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartSample2 extends StatefulWidget {
  double normal;
  double flaw;
  PieChartSample2({
    super.key,
    required this.normal,
    required this.flaw,
  });

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int touchedIndex = -1;
  double animatedValue = 0;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: AspectRatio(
        aspectRatio: 3,
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: PieChart(
                PieChartData(
                  startDegreeOffset: 270,
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
                  sections: showingSections(),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Indicator(
                  color: const Color(0xffD4A373),
                  text: '정상 원두 : ${widget.normal}', // 값 동적으로 표시,
                  isSquare: true,
                ),
                const SizedBox(
                  width: 10,
                ),
                const SizedBox(
                  width: 8, // Padding 대신 SizedBox의 width 사용
                ),
                Indicator(
                  color: const Color(0xffD9D9D9),
                  text: '결함 원두 : ${widget.flaw}', // 값 동적으로 표시
                  isSquare: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final value = i == 0 ? animatedValue : widget.flaw;
      return PieChartSectionData(
        color: i == 0 ? const Color(0xffD4A373) : const Color(0xffD9D9D9),
        value: value,
        title: '',
        showTitle: false,
      );
    });
  }

  @override
  void didUpdateWidget(PieChartSample2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // normal 또는 flaw 값이 변경될 때마다 애니메이션을 다시 시작
    if (widget.normal != oldWidget.normal || widget.flaw != oldWidget.flaw) {
      animatedValue = 0;
      startAnimation();
    }
  }

  void startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(
      const Duration(milliseconds: 1),
      (timer) {
        if (animatedValue < widget.normal) {
          setState(() {
            animatedValue += 0.1; // 혹은 보다 세밀한 조정을 원한다면 값을 조정하세요.
          });
        } else {
          timer.cancel();
        }
      },
    );
  }
}
