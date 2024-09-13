import 'dart:async';
import 'package:border_crossing_mobile/models/border/border.dart';
import 'package:border_crossing_mobile/models/error.dart';
import 'package:border_crossing_mobile/screens/main/border_times/border_times_screen.dart';
import 'package:border_crossing_mobile/services/border_crossing_service.dart';
import 'package:border_crossing_mobile/services/border_service.dart';
import 'package:border_crossing_mobile/services/settings_service.dart';
import 'package:border_crossing_mobile/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStreamSubscription;
  final SettingsService _settingsService = SettingsService();
  final BorderService _borderService = BorderService();
  final BorderCrossingService _borderCrossingService = BorderCrossingService();

  Position? _currentPosition;
  Position? _bordersLoadingPosition;
  LatLng? _lastPosition;

  Timer? _cameraUpdateTimer;
  final Duration _cameraUpdateThrottle = const Duration(milliseconds: 1000);
  final double _mapZoom = 14;

  List<BorderCheckpoint> _borders = [];
  bool _isUserInteracting = false;
  bool _isLoading = true;
  bool _bordersLoaded = false;
  bool _isAutomaticMode = false;
  Set<Marker> _markers = {};

  bool _insideGeofence = false;
  String? _activeBorderId;
  BorderCheckpoint? _activeBorder;
  String? _activeCrossingId;
  DateTime? _lastCrossingTime;

  @override
  void initState() {
    super.initState();
    _loadAutomaticMode();
    _requestLocationPermission();
    _loadCrossingData();
    _getActiveBorder();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _cameraUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      setState(() {
        _isLoading = false;
        if (status.isPermanentlyDenied) {
          openAppSettings();
        } else {
          SnackbarUtils.showSnackbar(context, 'Location permission is required to show your location.');
        }
      });
    }
  }

  Future<void> _loadAutomaticMode() async {
    final isAutomaticMode = await _settingsService.getAutomaticMode();
    setState(() {
      _isAutomaticMode = isAutomaticMode;
    });
  }

  Future<void> _loadCrossingData() async {
    _insideGeofence = await _borderCrossingService.getInsideGeofence();
    _activeBorderId = await _borderCrossingService.getActiveBorderId();
    _activeCrossingId = await _borderCrossingService.getActiveCrossingId();
    _lastCrossingTime = await _borderCrossingService.getLastCrossingTime();
  }

  Future<void> _validateCrossingData(Position position) async {
    try {
      final border = _activeBorder;
      if (border != null) {
        final double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          border.location.latitude,
          border.location.longitude,
        );

        if (distance >= 10000) {
          _borderCrossingService.clearCrossingData();
          _activeBorder = null;
        }
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
    }
  }

  Future<void> _loadBorders() async {
    try {
      final borders = await _borderService.getBorderCheckpointsByDistance(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
      );

      setState(() {
        _borders = borders ?? [];
        _bordersLoaded = true;

        _markers = _borders.map((border) {
          return Marker(
            markerId: MarkerId(border.id),
            position: LatLng(border.location.latitude, border.location.longitude),
            infoWindow: InfoWindow(
              title: '${border.name} (${border.countryFrom.name} ➔ ${border.countryTo.name})',
              snippet: 'Click to see waiting times...',
              onTap: () {
                _openBorderTimesScreen(border);
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          );
        }).toSet();
      });

    } catch (e) {
      if (e is BCError) {
        if (mounted) {
          SnackbarUtils.showSnackbar(context, e.message);
        }
      } else {
        if (mounted) {
          SnackbarUtils.showSnackbar(context, 'Failed to load border checkpoints.');
        }
      }
    }
  }

  Future<void> _getActiveBorder() async {
    if (_activeBorderId == null) {
      return;
    }
    try {
      final activeBorder = await _borderService.getBorderCheckpoint(_activeBorderId!);
      _activeBorder = activeBorder;
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
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).listen((Position position) {
        final currentLatLng = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentPosition = position;
          _bordersLoadingPosition ??= position;
          _isLoading = false;
        });

        if (_currentPosition != null && !_bordersLoaded) {
          _loadBorders(); // don't load borders every time
        }

        _loadBordersEvery100Kilometers();

        if (_isAutomaticMode) {
          if (_activeBorderId != null) {
            _validateCrossingData(position);
          }
          _checkGeofence(position);
        }

        if (!_isUserInteracting) {
          if (_lastPosition != currentLatLng) {
            _lastPosition = currentLatLng;
            _cameraUpdateTimer?.cancel();
            _cameraUpdateTimer = Timer(_cameraUpdateThrottle, () {
              _mapController?.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: currentLatLng,
                  zoom: _mapZoom,
                ),
              ));
            });
          }
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      SnackbarUtils.showSnackbar(context, 'Error fetching location');
    }
  }

  void _checkGeofence(Position userPosition) {
    for (BorderCheckpoint border in _borders) {
      final double entryDistance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        border.location.entryLatitude,
        border.location.entryLongitude,
      );

      final double exitDistance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        border.location.exitLatitude,
        border.location.exitLongitude,
      );

      if (entryDistance < 150 && !_insideGeofence) {
        _enteredBorder(border.id);
      }

      if (_insideGeofence && userPosition.speed < 2 && _activeBorderId == border.id) {
        _startCrossing(border.id);
      }

      if (exitDistance < 100 && _insideGeofence && _activeCrossingId != null) {
        _crossedBorder();
      }
    }
  }
  
  void _enteredBorder(String borderId) {
    if (_lastCrossingTime != null && _lastCrossingTime!.difference(DateTime.now()).inHours < 1) {
      return;
    }

    _insideGeofence = true;
    _activeBorderId = borderId;
    _lastCrossingTime = DateTime.now();

    _borderCrossingService.setActiveBorderId(borderId);
    _borderCrossingService.setInsideGeofence(true);
    _borderCrossingService.setLastCrossingTime();
  }

  Future<void> _startCrossing(String borderId) async {
    if (_activeCrossingId != null) {
      return;
    }
    try {
      final crossingId = await _borderCrossingService.arrivedAtBorder(borderId);

      if (crossingId != null) {
        _activeCrossingId = crossingId;
        _lastCrossingTime = DateTime.now();

        _borderCrossingService.setActiveCrossingId(crossingId);
        _borderCrossingService.setLastCrossingTime();

        if (mounted) {
          SnackbarUtils.showSnackbar(context,
              'Border waiting timer started.',
              seconds: 10,
              customColor: Colors.deepPurple[400]
          );
        }
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
    }
  }
  
  Future<void> _crossedBorder() async {
    try {
      if (_activeCrossingId != null) {
        await _borderCrossingService.crossedBorder(_activeCrossingId!);
        _insideGeofence = false;
        _activeCrossingId = null;
        _lastCrossingTime = DateTime.now();

        _borderCrossingService.setLastCrossingTime();
        _borderCrossingService.clearCrossingData();

        if (mounted) {
          SnackbarUtils.showSnackbar(context,
              'You have crossed the border. Have a nice trip!',
              seconds: 10,
              customColor: Colors.deepPurple[400]
          );
        }
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
    }
  }

  void _loadBordersEvery100Kilometers() {
    if (_bordersLoadingPosition != null && _currentPosition != null) {
      final double distance = Geolocator.distanceBetween(
        _bordersLoadingPosition!.latitude,
        _bordersLoadingPosition!.longitude,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (distance <= 100000) {
        _loadBorders();
      }
    }
  }

  void _recenterMap() {
    if (_currentPosition != null && _mapController != null) {
      final currentLatLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLatLng,
          zoom: _mapZoom,
        ),
      ));
      setState(() {
        _isUserInteracting = false;
      });
    }
  }

  void _openBorderTimesScreen(BorderCheckpoint border) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BorderTimesScreen(border: border),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (!_isLoading && _currentPosition != null)
            Listener(
              onPointerDown: (e) {
                setState(() {
                  _isUserInteracting = true;
                });
              },
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition != null
                      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                      : const LatLng(44.80241600, 20.46560100), // Default to Belgrade
                  zoom: _mapZoom,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (_currentPosition != null) {
                    _mapController!.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        zoom: _mapZoom,
                      ),
                    ));
                  }
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                trafficEnabled: true,
                mapToolbarEnabled: false,
                markers: _markers,
              ),
            ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _recenterMap,
              backgroundColor: Colors.deepPurple[100],
              foregroundColor: Colors.deepPurple[700],
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
