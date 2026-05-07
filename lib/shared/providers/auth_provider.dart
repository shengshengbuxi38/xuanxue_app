import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';
import '../../core/api_endpoints.dart';

final authProvider = StateNotifierProvider<AuthNotifier, String?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<String?> {
  final ApiClient _api = ApiClient();

  AuthNotifier() : super(null) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      state = token;
    }
  }

  void enterAsGuest() {
    state = 'guest';
  }

  Future<bool> login(String username, String password) async {
    try {
      final res = await _api.post(ApiEndpoints.login, data: {
        'username': username, 'password': password,
      });
      final token = res.data['access_token'] as String;
      await _api.saveToken(token);
      state = token;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    try {
      final res = await _api.post(ApiEndpoints.register, data: {
        'username': username, 'password': password,
      });
      final token = res.data['access_token'] as String;
      await _api.saveToken(token);
      state = token;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    state = null;
  }

  bool get isLoggedIn => state != null && state != 'guest';
  bool get isGuest => state == 'guest';
}
