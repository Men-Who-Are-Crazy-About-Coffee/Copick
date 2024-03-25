import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _comments = [
    '첫 번째 댓글입니다!',
    '두 번째 댓글입니다!',
    // 더 많은 댓글이 있을 수 있습니다.
  ];

  void _showModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        TextEditingController _commentController = TextEditingController();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_comments[index]),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: '댓글 추가...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      setState(() {
                        _comments.add(_commentController.text);
                        _commentController.clear();
                      });
                      // 모달을 닫고 싶지 않으면 아래 줄을 주석 처리하세요.
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('댓글 기능 예제'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showModalBottomSheet,
          child: Text('댓글 보기'),
        ),
      ),
    );
  }
}
