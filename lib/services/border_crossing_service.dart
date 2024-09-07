import 'dart:convert';

import 'package:border_crossing_mobile/constants/api_endpoints.dart';
import 'package:border_crossing_mobile/models/border/border_analytics.dart';
import 'package:border_crossing_mobile/models/border/border_crossing.dart';
import 'package:border_crossing_mobile/models/error.dart';
import 'package:border_crossing_mobile/services/auth_service.dart';
import 'package:http/http.dart' as http;

class BorderCrossingService {
  final AuthService _authService = AuthService();
  
  Future<List<BorderCrossing>?> getRecentCrossings(String borderId) async {
    final uri = Uri.parse('${ApiEndpoints.borderCrossing}/$borderId');

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
    final uri = Uri.parse('${ApiEndpoints.borderCrossing}/analytics/$borderId');

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

}