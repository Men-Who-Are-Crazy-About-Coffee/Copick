import 'package:dio/dio.dart';
import 'package:fe/src/models/user.dart';
import 'package:fe/src/services/api_service.dart';
import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  ApiService apiService = ApiService();

  User user = User();

  Future<void> fetchUserData() async {
    Response response = await apiService.get('/api/member/my');
    if (response.statusCode == 200) {
      user = User.fromJson(response.data);
      notifyListeners();
    } else {
      throw Exception('Failed to load user data');
    }
  }
}
