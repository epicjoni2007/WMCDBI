class AuthService {
  static String? _token;

  static Future<bool> login(String username, String password) async {
    // MVP: stub - accept any credentials and return a fake token
    await Future.delayed(const Duration(milliseconds: 200));
    _token = 'stub-token-for-$username';
    return true;
  }

  static Future<void> logout() async {
    _token = null;
  }

  static String? get token => _token;

  static bool get isAuthenticated => _token != null;
}
