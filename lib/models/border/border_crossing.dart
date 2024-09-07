import 'package:border_crossing_mobile/models/border/border.dart';
import 'package:border_crossing_mobile/utils/date_time_utils.dart';

class BorderCrossing {
  final String id;
  final DateTime arrivalTimestamp;
  final DateTime crossingTimestamp;
  final Duration duration;
  final BorderCheckpoint border;
  final String createdBy;

  BorderCrossing({
    required this.id,
    required this.arrivalTimestamp,
    required this.crossingTimestamp,
    required this.duration,
    required this.border,
    required this.createdBy,
  });

  factory BorderCrossing.fromJson(Map<String, dynamic> json) {
    return BorderCrossing(
      id: json['id'] as String,
      arrivalTimestamp: DateTime.parse(json['arrivalTimestamp']),
      crossingTimestamp: DateTime.parse(json['crossingTimestamp']),
      duration: DateTimeUtils.parseIso8601Duration(json['duration'] as String),
      border: BorderCheckpoint.fromJson(json['border']),
      createdBy: json['createdBy'] as String,
    );
  }

}
