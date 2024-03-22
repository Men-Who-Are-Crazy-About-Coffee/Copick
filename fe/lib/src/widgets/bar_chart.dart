import 'package:fe/src/resources/app_resources.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class _BarChart extends StatefulWidget {
  final double endValue;
  final double otherValue;
  const _BarChart({
    super.key,
    required this.endValue,
    required this.otherValue,
  });
  @override
  State<_BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<_BarChart>
    with SingleTickerProviderStateMixin {
  late double normal;
  late AnimationController _animationController;
  late Animation<double> _firstBarAnimation;
  late Animation<double> _secondBarAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2), // 애니메이션 지속 시간
      vsync: this,
    );

    _firstBarAnimation =
        Tween<double>(begin: 0, end: widget.otherValue).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.0, 0.5, // 애니메이션 지속 시간의 절반동안 실행
          curve: Curves.easeOut,
        ),
      ),
    )..addListener(() {
            setState(() {}); // UI 업데이트를 위해 setState 호출
          });

    _secondBarAnimation = Tween<double>(begin: 0, end: widget.endValue).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.5, 1.0, // 애니메이션 지속 시간의 나머지 절반동안 실행
          curve: Curves.easeOut,
        ),
      ),
    )..addListener(() {
        setState(() {}); // UI 업데이트를 위해 setState 호출
      });

    // 애니메이션 컨트롤러 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          const Text(
            '다른 사용자와 비교해볼게요.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            width: 400,
            height: 250,
            child: BarChart(
              BarChartData(
                barTouchData: barTouchData,
                titlesData: titlesData,
                borderData: borderData,
                barGroups: [
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: _firstBarAnimation.value,
                        color: const Color(0xffD9D9D9),
                        width: 50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: _secondBarAnimation.value,
                        color: const Color(0xffD4A373),
                        width: 50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                ],
                gridData: const FlGridData(show: false),
                alignment: BarChartAlignment.spaceEvenly,
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          widget.endValue == 0
              ? const Text('아직 날짜가 선택되지 않았어요')
              : widget.endValue == widget.otherValue
                  ? const Text('다른 사용자들의 평균과 동일해요.')
                  : widget.endValue > widget.otherValue
                      ? Text(
                          '다른 사용자들의 평균보다 ${widget.endValue - widget.otherValue}%p만큼 높아요.')
                      : Text(
                          '다른 사용자들의 평균보다 ${widget.otherValue - widget.endValue}%p만큼 낮아요.'),
          const SizedBox(
            height: 70,
          ),
        ],
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: -4,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: AppColors.contentColorBlack,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '나의 평균';
        break;
      case 1:
        text = '사용자 평균';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 2,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );
}

class BarChartSample3 extends StatefulWidget {
  final double normal;
  final double other;
  const BarChartSample3({
    super.key,
    required this.normal,
    required this.other,
  });

  @override
  State<StatefulWidget> createState() => BarChartSample3State();
}

class BarChartSample3State extends State<BarChartSample3> {
  @override
  Widget build(BuildContext context) {
    return _BarChart(
      endValue: widget.normal,
      otherValue: widget.other,
    );
  }
}
