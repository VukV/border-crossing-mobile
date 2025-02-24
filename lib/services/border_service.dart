import 'dart:convert';
import 'package:border_crossing_mobile/constants/api_endpoints.dart';
import 'package:border_crossing_mobile/models/border/border.dart';
import 'package:border_crossing_mobile/models/country.dart';
import 'package:border_crossing_mobile/models/error.dart';
import 'package:border_crossing_mobile/models/http/pageable_response.dart';
import 'package:border_crossing_mobile/services/auth_service.dart';
import 'package:http/http.dart' as http;

class BorderService {
  final AuthService _authService = AuthService();

  Future<BorderCheckpoint?> getBorderCheckpoint(String borderId) async {
    final uri = Uri.parse('${ApiEndpoints.border}/$borderId');

    try {
      final jwt = await _authService.getJwtToken();
      final headers = {
        'Content-Type': 'application/json',
        if (jwt != null) 'Authorization': 'Bearer $jwt',
      };
      final response = await http.patch(uri, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return BorderCheckpoint.fromJson(json);
      } else {
        final error = jsonDecode(response.body);
        return Future.error(BCError.fromJson(error));
      }
    } catch (e) {
      return Future.error(BCError(message: 'Unexpected error occurred.'));
    }
  }

  Future<PageableResponse<BorderCheckpoint>?> getBorderCheckpoints({
    required Country countryFrom,
    Country? countryTo,
    int page = 0,
    int size = 20,
  }) async {
    final queryParameters = {
      'countryFrom': countryFrom.name,
      if (countryTo != null) 'countryTo': countryTo.name,
      'page': page.toString(),
      'size': size.toString(),
    };
    final uri = Uri.parse(ApiEndpoints.border).replace(queryParameters: queryParameters);

    try {
      final jwt = await _authService.getJwtToken();
      final headers = {
        'Content-Type': 'application/json',
        if (jwt != null) 'Authorization': 'Bearer $jwt',
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return PageableResponse<BorderCheckpoint>.fromJson(
          jsonResponse, (item) => BorderCheckpoint.fromJson(item),
        );
      } else {
        final errorResponse = jsonDecode(response.body);
        return Future.error(BCError.fromJson(errorResponse));
      }
    } catch (e) {
      return Future.error(BCError(message: 'Failed to fetch checkpoints'));
    }
  }

  Future<List<BorderCheckpoint>?> getBorderCheckpointsByDistance({
    required double latitude,
    required double longitude,
    int kilometres = 1000
  }) async {
    final queryParameters = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'distance': kilometres.toString(),
    };

    final uri = Uri.parse('${ApiEndpoints.border}/distance').replace(queryParameters: queryParameters);

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
        return jsonList.map((json) => BorderCheckpoint.fromJson(json)).toList();
      } else {
        final errorResponse = jsonDecode(response.body);
        return Future.error(BCError.fromJson(errorResponse));
      }
    } catch (e) {
      return Future.error(BCError(message: 'Failed to fetch checkpoints'));
    }
  }

  Future<List<BorderCheckpoint>?> getFavoriteBorderCheckpoints() async {
    final uri = Uri.parse('${ApiEndpoints.border}/favourites');

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
        return jsonList.map((json) => BorderCheckpoint.fromJson(json)).toList();
      } else {
        final errorResponse = jsonDecode(response.body);
        return Future.error(BCError.fromJson(errorResponse));
      }
    } catch (e) {
      return Future.error(BCError(message: 'Failed to fetch favorite checkpoints'));
    }
  }

  Future<void> favoriteToggle(BorderCheckpoint border) async {
    final token = await _authService.getJwtToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final endpoint = border.favorite
        ? Uri.parse('${ApiEndpoints.border}/unfavourite/${border.id}')
        : Uri.parse('${ApiEndpoints.border}/favourite/${border.id}');

    try {
      final response = await http.patch(endpoint, headers: headers);

      if (response.statusCode != 200) {
        final errorResponse = jsonDecode(response.body);
        throw BCError.fromJson(errorResponse);
      }
    } catch (e) {
      throw BCError(message: 'Failed to toggle favorite status.');
    }
  }

}
