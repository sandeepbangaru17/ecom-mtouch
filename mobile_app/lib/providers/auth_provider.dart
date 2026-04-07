import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._apiClient);

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final ApiClient _apiClient;

  AppUser? _user;
  String? _token;
  bool _isLoading = false;
  bool _isBootstrapping = true;
  String? _errorMessage;

  AppUser? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isBootstrapping => _isBootstrapping;
  bool get isAuthenticated => _token != null && _user != null;
  String? get errorMessage => _errorMessage;

  Future<void> loadSession() async {
    final preferences = await SharedPreferences.getInstance();
    final storedToken = preferences.getString(_tokenKey);
    final storedUser = preferences.getString(_userKey);

    if (storedToken != null && storedUser != null) {
      _token = storedToken;
      _user = AppUser.fromJson(jsonDecode(storedUser) as Map<String, dynamic>);
    }
    _isBootstrapping = false;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return _handleAuth(() => _apiClient.login(email: email, password: password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _handleAuth(
      () => _apiClient.register(name: name, email: email, password: password),
    );
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _errorMessage = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
    await preferences.remove(_userKey);
    notifyListeners();
  }

  Future<bool> _handleAuth(
    Future<Map<String, dynamic>> Function() callback,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await callback();
      _token = response['access_token'] as String;
      _user = AppUser.fromJson(response['user'] as Map<String, dynamic>);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_tokenKey, _token!);
      await preferences.setString(_userKey, jsonEncode(_user!.toJson()));
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
