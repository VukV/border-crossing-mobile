import 'package:border_crossing_mobile/models/country.dart';
import 'package:border_crossing_mobile/services/auth_service.dart';
import 'package:border_crossing_mobile/utils/snackbar_utils.dart';
import 'package:border_crossing_mobile/widgets/bc_button_outline.dart';
import 'package:flutter/material.dart';
import 'package:border_crossing_mobile/models/user/profile.dart';
import 'package:border_crossing_mobile/services/settings_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SettingsService _settingsService = SettingsService();
  final AuthService _authService = AuthService();
  late Future<Profile> _profileFuture;
  bool _isAutomaticMode = false;
  Country _country = Country.SRB;

  @override
  void initState() {
    super.initState();
    _profileFuture = _getProfileInfo();
    _loadAutomaticMode();
    _loadSelectedCountry();
  }

  Future<void> _loadAutomaticMode() async {
    final isAutomaticMode = await _settingsService.getAutomaticMode();
    setState(() {
      _isAutomaticMode = isAutomaticMode;
    });
  }

  Future<void> _loadSelectedCountry() async {
    Country country = await _settingsService.getSelectedCountry();
    setState(() {
      _country = country;
    });
  }

  Future<Profile> _getProfileInfo() async {
    return _authService.getProfileInfo();
  }

  void _toggleAutomaticMode(bool value) async {
    await _settingsService.setAutomaticMode(value);
    setState(() {
      _isAutomaticMode = value;
    });
  }

  void _saveSelectedCountry(Country? selectedCountry) async {
    if (selectedCountry != null) {
      await _settingsService.saveSelectedCountry(selectedCountry);
      setState(() {
        _country = selectedCountry;
      });
    }
  }

  void _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showSnackbar(context, "Unexpected error. Couldn't logout");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Profile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final profile = snapshot.data!;

        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 100),
                          Text(
                            'Welcome back, ${profile.firstName}',
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.deepPurple.shade300,
                            child: Text(
                              profile.firstName.isNotEmpty
                                  ? profile.firstName[0]
                                  : '',
                              style: const TextStyle(fontSize: 55, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            profile.email,
                            style: TextStyle(fontSize: 18.0, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Manage your app settings below',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Automatic Mode',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Switch(
                            value: _isAutomaticMode,
                            onChanged: _toggleAutomaticMode,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'Select Country',
                              style: TextStyle(fontSize: 18.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 120.0, // Set the width of the DropdownButton here
                            child: DropdownButton<Country>(
                              isExpanded: true, // Ensures the dropdown fits within its container
                              value: _country,
                              dropdownColor: Colors.grey[300],
                              hint: const Text('Choose your country'),
                              items: Country.values.map((Country country) {
                                return DropdownMenuItem<Country>(
                                  value: country,
                                  child: Text(
                                    country.name.toUpperCase(),
                                    overflow: TextOverflow.ellipsis, // Handle overflow of text if needed
                                  ),
                                );
                              }).toList(),
                              onChanged: (Country? newCountry) {
                                _saveSelectedCountry(newCountry);
                              },
                            ),
                          ),
                        ],
                      )

                    ],
                  ),
                ),
              ),

              // Logout Button at the Bottom
              Padding(
                padding: const EdgeInsets.all(32),
                child: SizedBox(
                  width: double.infinity, // Make button full width
                  child: BCButtonOutline(
                    onPressed: _logout,
                    text: 'Logout',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
