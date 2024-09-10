import 'dart:async';
import 'package:border_crossing_mobile/models/border/border.dart';
import 'package:border_crossing_mobile/models/error.dart';
import 'package:border_crossing_mobile/screens/main/border_times/border_times_screen.dart';
import 'package:border_crossing_mobile/services/border_crossing_service.dart';
import 'package:border_crossing_mobile/services/border_service.dart';
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
  final BorderService _borderService = BorderService();
  final BorderCrossingService _borderCrossingService = BorderCrossingService();

  Position? _currentPosition;
  LatLng? _lastPosition;

  Timer? _cameraUpdateTimer;
  final Duration _cameraUpdateThrottle = const Duration(milliseconds: 1000);

  List<BorderCheckpoint> _borders = [];
  bool _isUserInteracting = false;
  bool _isLoading = true;
  bool _bordersLoaded = false;

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
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

  Future<void> _loadBorders() async {
    if (_currentPosition == null || _bordersLoaded) {
      return; // don't load borders every time
    }

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
                title: '${border.name} (${border.countryFrom.name}➔${border.countryTo.name})',
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

  Future<void> _getCurrentLocation() async {
    try {
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        final currentLatLng = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });

        _loadBorders();

        if (!_isUserInteracting) {
          if (_lastPosition != currentLatLng) {
            _lastPosition = currentLatLng;
            _cameraUpdateTimer?.cancel();
            _cameraUpdateTimer = Timer(_cameraUpdateThrottle, () {
              _mapController?.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: currentLatLng,
                  zoom: 15,
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

  void _recenterMap() {
    if (_currentPosition != null && _mapController != null) {
      final currentLatLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLatLng,
          zoom: 15,
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
                  zoom: 12,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (_currentPosition != null) {
                    _mapController!.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        zoom: 15,
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
