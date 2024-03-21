import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  Dio dio = Dio();

  String baseUrl = dotenv.env['BASE_URL']!;

  final storage = const FlutterSecureStorage();

  ApiService() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? accessToken = await storage.read(key: 'ACCESS_TOKEN');
        options.headers['Authorization'] = 'Bearer $accessToken';
        return handler.next(options);
      },
      onError: (DioError error, handler) async {
        // if (error.response?.statusCode == 401) {
        //   // Access token expired, attempt to refresh it
        //   String? refreshToken = await storage.read(key: 'REFRESH_TOKEN');
        //   if (refreshToken != null) {
        //     // Make a request to the token refresh endpoint
        //     try {
        //       Response refreshResponse = await dio.post(
        //         '$baseUrl/refresh_token',
        //         data: {'refresh_token': refreshToken},
        //       );

        //       print(refreshResponse.data);
        //       String newAccessToken = refreshResponse.data['access_token'];
        //       print(newAccessToken);

        //       // Update the access token in storage
        //       await storage.write(key: 'ACCESS_TOKEN', value: newAccessToken);
        //       // Update the request with the new access token and retry
        //       error.requestOptions.headers['Authorization'] =
        //           'Bearer $newAccessToken';
        //       final opts = Options(
        //         method: error.requestOptions.method,
        //         headers: error.requestOptions.headers,
        //       );
        //       // Retry the original request with the new access token
        //       return handler.resolve(await dio.request(
        //         baseUrl + error.requestOptions.path,
        //         options: opts,
        //         data: error.requestOptions.data,
        //         queryParameters: error.requestOptions.queryParameters,
        //       ));
        //     } catch (refreshError) {
        //       throw Exception('Failed to refresh access token: $refreshError');
        //     }
        //   } else {
        //     throw Exception('Refresh token not found');
        //   }
        // } else {
        //   // For other errors, just pass the error as is
        //   return handler.next(error);
        // }
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
}
