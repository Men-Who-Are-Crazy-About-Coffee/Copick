import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeleteStorage {
  final storage = const FlutterSecureStorage();

  Future<void> deleteAll() async {
    await storage.deleteAll();
  }

  Future<void> deleteTokens() async {
    await storage.delete(key: 'ACCESS_TOKEN');
    await storage.delete(key: 'REFRESH_TOKEN');
  }
}
