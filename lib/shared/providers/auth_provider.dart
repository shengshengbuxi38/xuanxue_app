import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';
import '../../core/api_endpoints.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<String?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<String?>> {
  final ApiClient _api = ApiClient();

  AuthNotifier() : super(const AsyncValue.data(null)) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    state = AsyncValue.data(token);
  }

  Future<bool> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final res = await _api.post(ApiEndpoints.login, data: {
        'username': username, 'password': password,
      });
      final token = res.data['access_token'] as String;
      await _api.saveToken(token);
      state = AsyncValue.data(token);
      return true;
    } catch (e) {
      state = const AsyncValue.data(null);
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final res = await _api.post(ApiEndpoints.register, data: {
        'username': username, 'password': password,
      });
      final token = res.data['access_token'] as String;
      await _api.saveToken(token);
      state = AsyncValue.data(token);
      return true;
    } catch (e) {
      state = const AsyncValue.data(null);
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    state = const AsyncValue.data(null);
  }

  bool get isLoggedIn => state.valueOrNull != null;
}
