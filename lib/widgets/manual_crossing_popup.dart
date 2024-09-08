import 'package:border_crossing_mobile/models/error.dart';
import 'package:border_crossing_mobile/services/border_crossing_service.dart';
import 'package:border_crossing_mobile/utils/snackbar_utils.dart';
import 'package:border_crossing_mobile/widgets/bc_button.dart';
import 'package:border_crossing_mobile/widgets/bc_button_outline.dart';
import 'package:flutter/material.dart';

class CrossingPopup extends StatefulWidget {
  final String borderId;
  final VoidCallback? onCallback;

  const CrossingPopup({
    super.key,
    required this.borderId,
    this.onCallback,
  });

  @override
  State<CrossingPopup> createState() => _CrossingPopupState();
}

class _CrossingPopupState extends State<CrossingPopup> {
  final BorderCrossingService _borderCrossingService = BorderCrossingService();
  TimeOfDay _arrivalTime = TimeOfDay.now();
  TimeOfDay _crossingTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _arrivalTime = subtractHalfHour(_crossingTime);
  }

  Future<void> _pickTime(BuildContext context, bool isStartTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _arrivalTime = pickedTime;
        } else {
          _crossingTime = pickedTime;
        }
      });
    }
  }

  Future<void> _submitData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _borderCrossingService.addCrossingTime(widget.borderId, _arrivalTime, _crossingTime);
      if (widget.onCallback != null) {
        widget.onCallback!();
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (e is BCError) {
        if (mounted) {
          SnackbarUtils.showSnackbar(context, e.message);
        }
      } else {
        if (mounted) {
          SnackbarUtils.showSnackbar(context, 'An unknown error occurred.');
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  TimeOfDay subtractHalfHour(TimeOfDay time) {
    final now = DateTime.now();
    DateTime dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    DateTime newDateTime = dateTime.subtract(const Duration(minutes: 30));
    return TimeOfDay(hour: newDateTime.hour, minute: newDateTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Times',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              title: Text('Arrival Time: ${_arrivalTime.format(context)}'),
              trailing: const Icon(
                Icons.timer_outlined,
                color: Colors.deepPurple,
              ),
              onTap: () => _pickTime(context, true),
            ),
            ListTile(
              title: Text('Crossing Time: ${_crossingTime.format(context)}'),
              trailing: const Icon(
                Icons.timer_off_outlined,
                color: Colors.deepPurple,
              ),
              onTap: () => _pickTime(context, false),
            ),
            const SizedBox(height: 16.0),
            Container(
              child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BCButton(
                    text: 'Submit',
                    onPressed: _submitData,
                  ),
                  const SizedBox(width: 8),
                  BCButtonOutline(
                    text: 'Cancel',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
