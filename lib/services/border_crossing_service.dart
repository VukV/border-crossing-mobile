import 'dart:convert';
import 'package:border_crossing_mobile/constants/api_endpoints.dart';
import 'package:border_crossing_mobile/models/border/border_analytics.dart';
import 'package:border_crossing_mobile/models/border/border_crossing.dart';
import 'package:border_crossing_mobile/models/error.dart';
import 'package:border_crossing_mobile/services/auth_service.dart';
import 'package:border_crossing_mobile/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BorderCrossingService {
  static const String _lastCrossingTimeKey = 'lastCrossingTime';
  static const String _insideGeofenceKey = 'lastCrossingTime';
  static const String _activeBorderIdKey = 'activeBorderId';
  static const String _activeCrossingIdKey = 'activeCrossingId';

  final AuthService _authService = AuthService();

  Future<void> setLastCrossingTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String formattedTime = now.toIso8601String();

    await prefs.setString(_lastCrossingTimeKey, formattedTime);
  }

  Future<DateTime?> getLastCrossingTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastCrossingTimeStr = prefs.getString(_lastCrossingTimeKey);

    if (lastCrossingTimeStr != null) {
      return DateTime.parse(lastCrossingTimeStr);
    }
    return null;
  }

  Future<void> setInsideGeofence(bool isInside) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_insideGeofenceKey, isInside);
  }

  Future<bool> getInsideGeofence() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_insideGeofenceKey) ?? false;
  }

  Future<void> setActiveCrossingId(String crossingId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeCrossingIdKey, crossingId);
  }

  Future<String?> getActiveCrossingId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeCrossingIdKey);
  }

  Future<void> setActiveBorderId(String crossingId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeBorderIdKey, crossingId);
  }

  Future<String?> getActiveBorderId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeBorderIdKey);
  }

  Future<void> clearCrossingData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_insideGeofenceKey);
    await prefs.remove(_activeCrossingIdKey);
    await prefs.remove(_activeBorderIdKey);
  }

  Future<List<BorderCrossing>?> getRecentCrossings(String borderId) async {
    final uri = Uri.parse('${ApiEndpoints.borderCrossing}/recent/$borderId');

    try {
      final jwt = await _authService.getJwtToken();
      final headers = {
        'Content-Type': 'application/json',
        if (jwt != null) 'Authorization': 'Bearer $jwt',
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> jsonList = jsonResponse as List<dynamic>;
        return jsonList.map((json) => BorderCrossing.fromJson(json)).toList();
      } else {
        final errorResponse = jsonDecode(response.body);
        return Future.error(BCError.fromJson(errorResponse));
      }
    } catch (e) {
      return Future.error(BCError(message: 'Failed to fetch recent crossings'));
    }
  }

  Future<BorderAnalytics?> getBorderAnalytics(String borderId) async {
    final timeZone = await FlutterTimezone.getLocalTimezone();
    final queryParameters = {
      'userTimeZone': timeZone
    };
    final uri = Uri.parse('${ApiEndpoints.borderCrossing}/analytics/$borderId').replace(queryParameters: queryParameters);

    try {
      final jwt = await _authService.getJwtToken();
      final headers = {
        'Content-Type': 'application/json',
        if (jwt != null) 'Authorization': 'Bearer $jwt',
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return BorderAnalytics.fromJson(jsonResponse);
      } else {
        final errorResponse = jsonDecode(response.body);
        return Future.error(BCError.fromJson(errorResponse));
      }
    } catch (e) {
      return Future.error(BCError(message: 'Failed to fetch border analytics'));
    }
  }

  Future<void> addCrossingTime(String borderId, TimeOfDay arrivalTime, TimeOfDay crossingTime) async {
    final uri = Uri.parse('${ApiEndpoints.borderCrossing}/manual/$borderId');

    DateTime arrivalDateTime = DateTimeUtils.convertToDateTime(arrivalTime);
    DateTime crossingDateTime = DateTimeUtils.convertToDateTime(crossingTime);

    if (arrivalDateTime.isAfter(crossingDateTime)) {
      return Future.error(BCError(message: "Crossing time can't be before arrival time."));
    }

    final String arrivalTimestamp = DateTimeUtils.toIso8601StringUTC(arrivalDateTime);
    final String crossingTimestamp = DateTimeUtils.toIso8601StringUTC(crossingDateTime);

    final body = jsonEncode({
      'arrivalTimestamp': arrivalTimestamp,
      'crossingTimestamp': crossingTimestamp
    });

    try {
      final jwt = await _authService.getJwtToken();
      final headers = {
        'Content-Type': 'application/json',
        if (jwt != null) 'Authorization': 'Bearer $jwt',
      };
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        return;
      } else {
        final error = jsonDecode(response.body);
        return Future.error(BCError.fromJson(error));
      }
    } catch (e) {
      return Future.error(BCError(message: 'Unexpected error occurred.'));
    }
  }

  Future<BorderCrossing?> arrivedAtBorder(String borderId) async {
    final uri = Uri.parse('${ApiEndpoints.borderCrossing}/$borderId');

    try {
      final jwt = await _authService.getJwtToken();
      final headers = {
        'Content-Type': 'application/json',
        if (jwt != null) 'Authorization': 'Bearer $jwt',
      };
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return BorderCrossing.fromJson(json);
      } else {
        final error = jsonDecode(response.body);
        return Future.error(BCError.fromJson(error));
      }
    } catch (e) {
      return Future.error(BCError(message: 'Unexpected error occurred.'));
    }
  }

  Future<void> crossedBorder(String crossingId) async {
    final uri = Uri.parse('${ApiEndpoints.borderCrossing}/$crossingId');

    try {
      final jwt = await _authService.getJwtToken();
      final headers = {
        'Content-Type': 'application/json',
        if (jwt != null) 'Authorization': 'Bearer $jwt',
      };
      final response = await http.patch(uri, headers: headers);

      if (response.statusCode == 200) {
        return;
      } else {
        final error = jsonDecode(response.body);
        return Future.error(BCError.fromJson(error));
      }
    } catch (e) {
      return Future.error(BCError(message: 'Unexpected error occurred.'));
    }
  }

}