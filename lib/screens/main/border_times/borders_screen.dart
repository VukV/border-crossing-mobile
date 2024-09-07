import 'dart:async';
import 'package:border_crossing_mobile/models/border/border.dart';
import 'package:border_crossing_mobile/models/country.dart';
import 'package:border_crossing_mobile/models/error.dart';
import 'package:border_crossing_mobile/services/border_service.dart';
import 'package:border_crossing_mobile/services/settings_service.dart';
import 'package:border_crossing_mobile/utils/snackbar_utils.dart';
import 'package:border_crossing_mobile/widgets/border_widget.dart';
import 'package:border_crossing_mobile/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';

class BordersScreen extends StatefulWidget {
  const BordersScreen({super.key});

  @override
  State<BordersScreen> createState() => _BordersScreenState();
}

class _BordersScreenState extends State<BordersScreen> {
  final SettingsService _settingsService = SettingsService();
  final BorderService _borderService = BorderService();
  Country? _countryFrom;
  Country? _countryTo;
  List<BorderCheckpoint> _borderCheckpoints = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedCountry();
  }

  Future<void> _loadSelectedCountry() async {
    Country country = await _settingsService.getSelectedCountry();
    setState(() {
      _countryFrom = country;
    });
    _loadBorders();
  }

  Future<void> _loadBorders() async {
    if (_countryFrom == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _borderService.getBorderCheckpoints(
        countryFrom: _countryFrom!,
        countryTo: _countryTo
      );

      if (response != null) {
        setState(() {
          _borderCheckpoints = response.content;
        });
      }
    } catch (e) {
      if (e is BCError) {
        if (mounted) {
          SnackbarUtils.showSnackbar(context, e.message);
        }
      } else {
        if (mounted) {
          SnackbarUtils.showSnackbar(context, 'An unknown error occurred.');
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top section with gradient, title, and dropdowns
          Stack(
            children: [
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
                                  dropdownColor: Colors.white,
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
                                    _loadBorders(); // Reload borders when country changes
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
                                  dropdownColor: Colors.white,
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
                                    _loadBorders(); // Reload borders when country changes
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

          // List of border checkpoints
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _borderCheckpoints.isEmpty
                  ? const EmptyStateWidget(passedText: 'checkpoints')
                  : ListView.builder(
                itemCount: _borderCheckpoints.length,
                itemBuilder: (context, index) {
                  final checkpoint = _borderCheckpoints[index];
                  return BorderCheckpointWidget(border: checkpoint);
                },
              ),
            ),
          )

        ],
      ),
    );
  }
}
