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

  Future<PageableResponse<BorderCheckpoint>?> getCheckpoints({
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
    final uri = Uri.parse(ApiEndpoints.borders).replace(queryParameters: queryParameters);

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

}
