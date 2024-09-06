import 'package:border_crossing_mobile/models/border/border.dart';
import 'package:border_crossing_mobile/services/border_service.dart';
import 'package:border_crossing_mobile/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';

class BorderCheckpointWidget extends StatefulWidget {
  final BorderCheckpoint border;
  final VoidCallback onFavoriteToggle;

  const BorderCheckpointWidget({
    super.key,
    required this.border,
    required this.onFavoriteToggle,
  });

  @override
  _BorderCheckpointWidgetState createState() => _BorderCheckpointWidgetState();
}

class _BorderCheckpointWidgetState extends State<BorderCheckpointWidget> {
  bool _isLoading = false; // State to manage the loading indicator
  final borderService = BorderService();

  Future<void> _toggleFavorite() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the API to update the favorite status
      await Future.delayed(const Duration(seconds: 1));
      // Notify parent to update state
      widget.onFavoriteToggle();
    } catch (e) {
      // Handle errors (e.g., show a snackbar)
      if (mounted) {
        SnackbarUtils.showSnackbar(context, 'Failed to update favorite status.');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                '${widget.border.countryFrom.name.toUpperCase()} → ${widget.border.countryTo.name.toUpperCase()}',
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
    );
  }
}
