import 'package:flutter/material.dart';

class RoundedButton extends StatefulWidget {
  final String maintext;
  final Color bgcolor;
  final VoidCallback? onPressed;
  const RoundedButton({
    super.key,
    required this.maintext,
    required this.bgcolor,
    this.onPressed,
  });

  @override
  State<RoundedButton> createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.bgcolor, // AppColors.color2가 정의되어 있어야 합니다.
        minimumSize: const Size(600, 60), // 버튼의 최소 크기 설정
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 모서리 둥근 정도 설정
        ),
      ),
      child: Text(
        widget.maintext, // 'widget.'를 사용하여 상위 위젯의 변수에 접근
        style: const TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }
}
