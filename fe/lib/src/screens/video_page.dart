export 'video_page_stub.dart'
    if (dart.library.io) 'video_page_mobile.dart' // 모바일 (dart:io 사용 가능)
    if (dart.library.html) 'video_page_web.dart'; // 웹 (dart:html 사용 가능)
