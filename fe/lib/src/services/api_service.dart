import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  Dio dio = Dio();

  String baseUrl = dotenv.env['BASE_URL']!;

  final storage = const FlutterSecureStorage();

  ApiService() {
    dio.options.followRedirects = true;

    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      // 기기에 저장된 AccessToken 로드
      String? accessToken = await storage.read(key: 'ACCESS_TOKEN');
      // 매 요청마다 헤더에 AccessToken을 포함
      options.headers['Authorization'] = 'Bearer $accessToken';
    
      return handler.next(options); // 요청을 계속 진행
    }, onError: (error, handler) {
      // 오류 처리를 위한 코드를 여기에 작성할 수 있습니다.
      return handler.next(error);
    }));
  }

  Future<Response> get(String url) async {
    Response response;
    try {
      response = await dio.get(baseUrl + url);
    } on Error catch (e) {
      // 요청 실패 시 처리
      throw Exception('Failed to load data: $e');
    }
    return response;
  }

  Future<Response> post(String url, {dynamic data}) async {
    Response response;
    try {
      response = await dio.post(baseUrl + url, data: data);
    } on Error catch (e) {
      // 요청 실패 시 처리
      throw Exception('Failed to load data: $e');
    }
    return response;
  }

  Future<Response> put(String url, {dynamic data}) async {
    Response response;
    try {
      response = await dio.put(baseUrl + url, data: data);
    } on Error catch (e) {
      // 요청 실패 시 처리
      throw Exception('Failed to load data: $e');
    }
    return response;
  }

  Future<Response> delete(String url) async {
    Response response;
    try {
      response = await dio.delete(baseUrl + url);
    } on Error catch (e) {
      // 요청 실패 시 처리
      throw Exception('Failed to load data: $e');
    }
    return response;
  }
}
