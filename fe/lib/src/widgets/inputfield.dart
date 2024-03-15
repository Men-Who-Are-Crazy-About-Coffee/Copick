import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  const InputField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = true; // 처음에는 비밀번호를 숨깁니다.
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isPassword = widget.label.toLowerCase() == 'password';

    return TextField(
      controller: widget.controller,
      obscureText: isPassword ? _isObscured : false, // 비밀번호일 경우 가시성 토글
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: Colors.grey[200],
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
        // 비밀번호 필드에 대해 가시성 버튼 추가
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  // 가시성 상태에 따라 아이콘 변경
                  _isObscured ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
      ),
      keyboardType:
          isPassword ? TextInputType.text : TextInputType.emailAddress,
    );
  }
}
