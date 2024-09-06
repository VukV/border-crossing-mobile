import 'package:border_crossing_mobile/models/country.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _automaticModeKey = 'automaticMode';
  static const String _selectedCountryKey = 'selectedCountry';

  Future<bool> getAutomaticMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_automaticModeKey) ?? false;
  }

  Future<void> setAutomaticMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_automaticModeKey, value);
  }

  Future<void> saveSelectedCountry(Country selectedCountry) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCountryKey, selectedCountry.name);
  }

  Future<Country> getSelectedCountry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? countryString = prefs.getString(_selectedCountryKey);

    if (countryString != null) {
      return Country.values.byName(countryString);
    } else {
      await prefs.setString(_selectedCountryKey, Country.SRB.name);
    }
    return Country.SRB;
  }

}
