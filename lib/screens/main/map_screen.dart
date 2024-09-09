import 'dart:async';
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
  Position? _currentPosition;
  bool _isLoading = true;
  StreamSubscription<Position>? _positionStreamSubscription;
  LatLng? _lastPosition;
  Timer? _cameraUpdateTimer;
  final Duration _cameraUpdateThrottle = const Duration(milliseconds: 1000);
  bool _isUserInteracting = false;

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
                  target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  zoom: 15,
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
