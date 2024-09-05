import 'dart:convert';
import 'package:border_crossing_mobile/constants/api_endpoints.dart';
import 'package:border_crossing_mobile/models/error.dart';
import 'package:border_crossing_mobile/models/user/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user/user.dart';

class AuthService {

  static const String _loginKey = 'isLoggedIn';
  static const String _jwtTokenKey = 'jwt';
  static const String _emailKey = 'email';
  static const String _firstNameKey = 'firstName';

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  Future<String?> getJwtToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jwtTokenKey);
  }

  Future<Profile> getProfileInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Profile(email: prefs.getString(_emailKey)?? '', firstName: prefs.getString(_firstNameKey)?? '');
  }

  Future<User?> login(String email, String password) async {
    final url = Uri.parse(ApiEndpoints.login);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final user = User.fromJson(jsonResponse);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_loginKey, true);
        await prefs.setString(_emailKey, user.email);
        await prefs.setString(_firstNameKey, user.firstName);
        if (user.accessToken != null) {
          await prefs.setString(_jwtTokenKey, user.accessToken!);
        }

        return user;
      } else {
        final error = jsonDecode(response.body);
        return Future.error(BCError.fromJson(error));
      }
    } catch (e) {
      return Future.error(BCError(message: 'Unexpected error during login'));
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginKey);
    await prefs.remove(_jwtTokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_firstNameKey);
  }

}