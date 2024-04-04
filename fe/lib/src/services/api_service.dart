import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:fe/src/services/delete_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  Dio dio = Dio();

  String baseUrl = dotenv.env['BASE_URL']!;
  String baseUrl2 = 'https://ai.copick.duckdns.org';

  final storage = const FlutterSecureStorage();

  ApiService() {
    bool refresh = true;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? accessToken = await storage.read(key: 'ACCESS_TOKEN');
        options.headers['Authorization'] = 'Bearer $accessToken';
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 404 ||
            error.response?.statusCode == 400) {
          handler.next(error);
        } else if (error.response?.statusCode == 401 && refresh) {
          String? refreshToken = await storage.read(key: 'REFRESH_TOKEN');
          if (refreshToken != null) {
            try {
              refresh = false;

              Dio dio = Dio();
              Response refreshResponse = await dio.post(
                "$baseUrl/api/auth/refresh",
                data: {"refreshToken": refreshToken},
              );
              print(refreshResponse.data);
              String newAccessToken = refreshResponse.data["accessToken"];
              await storage.write(key: 'ACCESS_TOKEN', value: newAccessToken);
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              final opts = Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers,
              );

              return handler.resolve(await dio.request(
                baseUrl + error.requestOptions.path,
                options: opts,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              ));
            } catch (refreshError) {
              return;
            }
          } else {
            throw Exception('Refresh token not found');
          }
        } else if (error.response?.statusCode == 401 && refresh) {
          DeleteStorage deleteStorage = DeleteStorage();
          deleteStorage.deleteAll();
        }
      },
    ));
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

  Future<String?> sendImage(XFile file, int resultIndex) async {
    var url = '$baseUrl2/api/python/analyze'; // 이미지 분석 API 엔드포인트
    Uint8List fileBytes = await file.readAsBytes(); // 파일 바이트 로드
    MultipartFile multipartFile = MultipartFile.fromBytes(fileBytes,
        filename: file.name); // MultipartFile 생성

    // 인증 토큰 읽기
    String? accessToken = await storage.read(key: 'ACCESS_TOKEN');

    // FormData 생성
    FormData formData = FormData.fromMap({
      "resultIndex": resultIndex, // 추가 데이터 (예: 결과 인덱스)
      "file": multipartFile, // 이미지 파일
    });

    try {
      // 요청 옵션에 헤더 추가
      Options options = Options(
        headers: {
          "Authorization": "Bearer $accessToken",
        },
      );

      Response response = await dio.post(url, data: formData, options: options);
      if (response.statusCode == 200) {
        String imageUrl = response.data;
        print(imageUrl);
        return imageUrl;
      } else {
        print("서버 오류: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("업로드 실패: $e");
      return null;
    }
  }
}
