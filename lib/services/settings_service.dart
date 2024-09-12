import 'package:border_crossing_mobile/constants/shared_preference_keys.dart';
import 'package:border_crossing_mobile/models/country.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {

  Future<bool> getAutomaticMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SharedPreferenceKeys.automaticModeKey) ?? false;
  }

  Future<void> setAutomaticMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPreferenceKeys.automaticModeKey, value);
  }

  Future<void> saveSelectedCountry(Country selectedCountry) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(selectedCountry);
    await prefs.setString(SharedPreferenceKeys.selectedCountryKey, selectedCountry.name);
  }

  Future<Country> getSelectedCountry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? countryString = prefs.getString(SharedPreferenceKeys.selectedCountryKey);

    if (countryString != null) {
      return Country.values.byName(countryString);
    } else {
      await prefs.setString(SharedPreferenceKeys.selectedCountryKey, Country.SRB.name);
    }
    return Country.SRB;
  }

}
