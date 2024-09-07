class BorderAnalytics {
  final int averageToday;
  final int averageWeek;
  final int averageMonth;
  final int averageCurrentHour;
  final List<AverageByHour> averageByHour;

  BorderAnalytics({
    required this.averageToday,
    required this.averageWeek,
    required this.averageMonth,
    required this.averageCurrentHour,
    required this.averageByHour,
  });

  factory BorderAnalytics.fromJson(Map<String, dynamic> json) {
    var averageByHourFromJson = json['averageByHour'] as List<dynamic>;
    List<AverageByHour> averageByHourList = averageByHourFromJson
        .map((e) => AverageByHour.fromJson(e as Map<String, dynamic>))
        .toList();

    return BorderAnalytics(
      averageToday: json['averageToday'] as int,
      averageWeek: json['averageWeek'] as int,
      averageMonth: json['averageMonth'] as int,
      averageCurrentHour: json['averageCurrentHour'] as int,
      averageByHour: averageByHourList,
    );
  }

}

class AverageByHour {
  final int hourOfDay;
  final int averageDuration;

  AverageByHour({
    required this.hourOfDay,
    required this.averageDuration,
  });

  factory AverageByHour.fromJson(Map<String, dynamic> json) {
    return AverageByHour(
      hourOfDay: json['hourOfDay'] as int,
      averageDuration: json['averageDuration'] as int,
    );
  }

}
