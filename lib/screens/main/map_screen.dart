import 'dart:async';

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
  Position? _currentPosition;
  bool _isLoading = true;
  StreamSubscription<Position>? _positionStreamSubscription;
  LatLng? _lastPosition;
  final _cameraUpdateThrottle = Duration(milliseconds: 1000); // Throttle duration
  Timer? _cameraUpdateTimer;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _cameraUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      // Permission is granted, get current location
      getCurrentLocation();
    } else if (status.isDenied) {
      // Permission is denied
      print('Location permission denied');
      setState(() {
        _isLoading = false; // Set loading to false when permission is denied
      });
    } else if (status.isPermanentlyDenied) {
      // Permission is permanently denied, open settings
      openAppSettings();
      setState(() {
        _isLoading = false; // Set loading to false when permission is permanently denied
      });
    }
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high, // High accuracy for GPS
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });

        if (_mapController != null) {
          final currentLatLng = LatLng(position.latitude, position.longitude);
          if (_lastPosition == null || _lastPosition != currentLatLng) {
            _lastPosition = currentLatLng;

            // Throttle the camera updates
            _cameraUpdateTimer?.cancel();
            _cameraUpdateTimer = Timer(_cameraUpdateThrottle, () {
              _mapController!.moveCamera(CameraUpdate.newCameraPosition(
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
      print('Error getting location: $e');
      setState(() {
        _isLoading = false; // Set loading to false when there is an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : LatLng(37.7749, -122.4194), // Default to San Francisco
              zoom: 12,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                _mapController!.moveCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    zoom: 15,
                  ),
                ));
              }
            },
            myLocationEnabled: true, // Shows the blue dot for the user's location
            myLocationButtonEnabled: true, // Shows the My Location button
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
