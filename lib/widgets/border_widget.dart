import 'package:border_crossing_mobile/models/border/border.dart';
import 'package:border_crossing_mobile/models/error.dart';
import 'package:border_crossing_mobile/screens/main/border_times/border_times_screen.dart';
import 'package:border_crossing_mobile/services/border_service.dart';
import 'package:border_crossing_mobile/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';

class BorderCheckpointWidget extends StatefulWidget {
  final BorderCheckpoint border;
  final VoidCallback? onToggleCallback;

  const BorderCheckpointWidget({
    super.key,
    required this.border,
    this.onToggleCallback
  });

  @override
  State<BorderCheckpointWidget> createState() => BorderCheckpointWidgetState();
}

class BorderCheckpointWidgetState extends State<BorderCheckpointWidget> {
  bool _isLoading = false;
  final BorderService _borderService = BorderService();

  Future<void> _toggleFavorite() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _borderService.favoriteToggle(widget.border);
      setState(() {
        widget.border.favorite = !widget.border.favorite;
      });
      if (widget.onToggleCallback != null) {
        widget.onToggleCallback!();
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

  void _onTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BorderTimesScreen(border: widget.border),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.deepPurple,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.border.name,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '${widget.border.countryFrom.name.toUpperCase()} ➔ ${widget.border.countryTo.name.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isLoading)
                    const CircularProgressIndicator(strokeWidth: 4)
                  else
                    IconButton(
                      icon: Icon(
                        widget.border.favorite ? Icons.star : Icons.star_border,
                        color: widget.border.favorite ? Colors.deepPurple : Colors.grey,
                      ),
                      iconSize: 32,
                      onPressed: _toggleFavorite,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
