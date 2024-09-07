import 'package:flutter/material.dart';
import 'package:border_crossing_mobile/models/border/border_crossing.dart';
import 'package:intl/intl.dart';

class BorderTimeWidget extends StatelessWidget {
  final BorderCrossing borderCrossing;

  const BorderTimeWidget({
    super.key,
    required this.borderCrossing,
  });

  Color _getDurationColor(Duration duration) {
    if (duration <= const Duration(minutes: 30)) {
      return Colors.green;
    } else if (duration > const Duration(minutes: 30) && duration <= const Duration(hours: 1)) {
      return const Color(0xFFFFD71E);
    } else {
      return const Color(0xFFD90F0F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arrivalTime = DateFormat('HH:mm').format(borderCrossing.arrivalTimestamp);
    final crossingTime = DateFormat('HH:mm').format(borderCrossing.crossingTimestamp);
    final date = DateFormat('dd MMM').format(borderCrossing.arrivalTimestamp);
    final durationInMinutes = borderCrossing.duration.inMinutes;
    final durationFormatted = durationInMinutes < 60
        ? '${durationInMinutes % 60}m'
        : '${durationInMinutes ~/ 60}h ${durationInMinutes % 60}m';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: _getDurationColor(borderCrossing.duration),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Arrived: ',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: arrivalTime,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Crossed: ',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: crossingTime,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: _getDurationColor(borderCrossing.duration),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  durationFormatted,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${borderCrossing.createdBy}, $date',
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
