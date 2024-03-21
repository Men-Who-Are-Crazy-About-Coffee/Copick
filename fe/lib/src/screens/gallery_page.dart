import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CommentBox(),
      // Center(
      //     child: Text(
      //   "갤러리 페이지입니다.",
      //   style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      // )),
    );
  }
}

class CommentBox extends StatefulWidget {
  const CommentBox({super.key});

  @override
  _CommentBoxState createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  final String _comment =
      '이 텍스트는 예시로 사용되는 긴 텍스트입니다. 필요에 따라 내용을 변경하세요. 이 텍스트가 너무 길 경우, 사용자는 전체 내용을 볼 수 있도록 "더보기"를 누를 수 있습니다.';
  bool _isExpanded = false;
  String img =
      "https://jariyo-s3.s3.ap-northeast-2.amazonaws.com/memeber/anonymous.png";

  final storage = const FlutterSecureStorage();
  Future<void> isLogin() async {
    String? accessToekn = await storage.read(key: "ACCESS_TOKEN");
    if (accessToekn == null) Navigator.pushNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    isLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCrossFade(
            firstChild: Text(
              _comment,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(_comment),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(_isExpanded ? "접기" : "더보기"),
          ),
          Image.network(img),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/vertical');
            },
            child: const Text("2"),
          ),
        ],
      ),
    );
  }
}
