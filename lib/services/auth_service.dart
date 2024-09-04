import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  static const String _loginKey = 'isLoggedIn';
  static const String _jwtTokenKey = 'jwt';

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  Future<String?> getJwtToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jwtTokenKey);
  }

}