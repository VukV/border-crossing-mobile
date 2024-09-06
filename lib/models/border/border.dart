import 'package:border_crossing_mobile/models/border/location.dart';
import 'package:border_crossing_mobile/models/country.dart';

class BorderCheckpoint {
  final String id;
  final String name;
  final Country countryFrom;
  final Country countryTo;
  final Location location;
  bool favorite;

  BorderCheckpoint({
    required this.id,
    required this.name,
    required this.countryFrom,
    required this.countryTo,
    required this.location,
    required this.favorite
  });

  factory BorderCheckpoint.fromJson(Map<String, dynamic> json) {
    return BorderCheckpoint(
      id: json['id'],
      name: json['name'],
      countryFrom: Country.values.firstWhere((e) =>
      e.name == json['countryFrom']),
      countryTo: Country.values.firstWhere((e) => e.name == json['countryTo']),
      location: Location.fromJson(json['location']),
      favorite: json['favorite']
    );
  }

}