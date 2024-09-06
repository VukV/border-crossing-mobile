class Location {
  final double longitude;
  final double latitude;
  final double entryLongitude;
  final double entryLatitude;
  final double exitLongitude;
  final double exitLatitude;

  Location({
    required this.longitude,
    required this.latitude,
    required this.entryLongitude,
    required this.entryLatitude,
    required this.exitLongitude,
    required this.exitLatitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      longitude: json['longitude'],
      latitude: json['latitude'],
      entryLongitude: json['entryLongitude'],
      entryLatitude: json['entryLatitude'],
      exitLongitude: json['exitLongitude'],
      exitLatitude: json['exitLatitude'],
    );
  }

}