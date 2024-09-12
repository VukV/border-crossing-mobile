import 'dart:convert';
import 'package:border_crossing_mobile/constants/api_endpoints.dart';
import 'package:border_crossing_mobile/constants/shared_preference_keys.dart';
import 'package:border_crossing_mobile/models/error.dart';
import 'package:border_crossing_mobile/models/user/profile.dart';
import 'package:border_crossing_mobile/models/user/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SharedPreferenceKeys.loginKey) ?? false;
  }

  Future<String?> getJwtToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedPreferenceKeys.jwtTokenKey);
  }

  Future<Profile> getProfileInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Profile(email: prefs.getString(SharedPreferenceKeys.emailKey)?? '', firstName: prefs.getString(SharedPreferenceKeys.firstNameKey)?? '');
  }

  Future<User?> login(String email, String password) async {
    if (email.isEmpty) {
      return Future.error(BCError(message: 'Email is not provided.'));
    }
    if (password.isEmpty) {
      return Future.error(BCError(message: 'Password is not provided.'));
    }

    final url = Uri.parse(ApiEndpoints.login);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final user = User.fromJson(jsonResponse);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool(SharedPreferenceKeys.loginKey, true);
        await prefs.setString(SharedPreferenceKeys.emailKey, user.email);
        await prefs.setString(SharedPreferenceKeys.firstNameKey, user.firstName);
        if (user.accessToken != null) {
          await prefs.setString(SharedPreferenceKeys.jwtTokenKey, user.accessToken!);
        }

        return user;
      } else {
        final error = jsonDecode(response.body);
        return Future.error(BCError.fromJson(error));
      }
    } catch (e) {
      return Future.error(BCError(message: 'Unexpected error during login.'));
    }
  }

  Future<void> register(String email, String password, String repeatPassword, String firstName, String lastName) async {
    if (email.isEmpty || password.isEmpty || repeatPassword.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      return Future.error(BCError(message: 'You need to fill in registration form.'));
    }
    if (password != repeatPassword) {
      return Future.error(BCError(message: 'Passwords do not match.'));
    }

    final url = Uri.parse(ApiEndpoints.register);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': email,
      'password': password,
      'repeatPassword': repeatPassword,
      'firstName': firstName,
      'lastName' : lastName
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return;
      } else {
        final error = jsonDecode(response.body);
        return Future.error(BCError.fromJson(error));
      }
    } catch (e) {
      return Future.error(BCError(message: 'Unexpected error during login.'));
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharedPreferenceKeys.loginKey);
    await prefs.remove(SharedPreferenceKeys.jwtTokenKey);
    await prefs.remove(SharedPreferenceKeys.emailKey);
    await prefs.remove(SharedPreferenceKeys.firstNameKey);
  }

}