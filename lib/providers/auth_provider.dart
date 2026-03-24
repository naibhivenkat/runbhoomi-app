import 'package:flutter/material.dart';
import '../core/secure_storage.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {

  bool isLoading = false;

  Future login(String email, String password) async {

    isLoading = true;
    notifyListeners();

    final res = await AuthService.login(email, password);

    if (res["token"] != null) {
      await SecureStorage.saveToken(res["token"]);
    }

    isLoading = false;
    notifyListeners();

    return res;
  }

  Future logout() async {
    await SecureStorage.clear();
    notifyListeners();
  }

}