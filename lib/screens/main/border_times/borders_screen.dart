import 'package:border_crossing_mobile/models/country.dart';
import 'package:border_crossing_mobile/services/settings_service.dart';
import 'package:flutter/material.dart';

class BordersScreen extends StatefulWidget {
  const BordersScreen({super.key});

  @override
  State<StatefulWidget> createState() => _BordersScreenState();
}

class _BordersScreenState extends State<BordersScreen> {
  final SettingsService _settingsService = SettingsService();
  Country _country = Country.SRB;
  Country? _countryFrom = null;
  Country? countryFrom = null;
  Country? _countryTo = null;

  @override
  void initState() {
    super.initState();
    _loadSelectedCountry();
  }

  Future<void> _loadSelectedCountry() async {
    Country country = await _settingsService.getSelectedCountry();
    setState(() {
      _country = country;
      countryFrom ??= country;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background with a curved shape
          Container(
            height: MediaQuery.of(context).size.height * 0.3, // Adjust height
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Color(0xFF845FFF)], // Purple gradient
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60.0),
                bottomRight: Radius.circular(60.0),
              ),
            ),
          ),

          // Content (title, subtitle, and dropdowns)
          Positioned.fill(
            top: 60.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Border Checkpoints',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Choose your checkpoint',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: DropdownButton<Country>(
                              isExpanded: true,
                              underline: const SizedBox.shrink(),
                              value: _countryFrom,
                              hint: const Text('Country From'),
                              items: Country.values.map((Country country) {
                                return DropdownMenuItem<Country>(
                                  value: country,
                                  child: Text(country.name.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (Country? newCountryFrom) {
                                setState(() {
                                  _countryFrom = newCountryFrom;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: DropdownButton<Country>(
                              isExpanded: true,
                              underline: const SizedBox.shrink(),
                              value: _countryTo,
                              hint: const Text('Country To'),
                              items: Country.values.map((Country country) {
                                return DropdownMenuItem<Country>(
                                  value: country,
                                  child: Text(country.name.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (Country? newCountryTo) {
                                setState(() {
                                  _countryTo = newCountryTo;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
