import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _automaticModeKey = 'automaticMode';

  Future<bool> getAutomaticMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_automaticModeKey) ?? false;
  }

  Future<void> setAutomaticMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_automaticModeKey, value);
  }

}
