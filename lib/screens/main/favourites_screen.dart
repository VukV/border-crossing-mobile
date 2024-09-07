import 'package:border_crossing_mobile/models/border/border.dart';
import 'package:border_crossing_mobile/models/error.dart';
import 'package:border_crossing_mobile/services/border_service.dart';
import 'package:border_crossing_mobile/utils/snackbar_utils.dart';
import 'package:border_crossing_mobile/widgets/border_widget.dart';
import 'package:border_crossing_mobile/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with TickerProviderStateMixin {
  final BorderService _borderService = BorderService();
  List<BorderCheckpoint> _favorites = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = await _borderService.getFavoriteBorderCheckpoints();
      if (favorites != null) {
        setState(() {
          _favorites = favorites;
        });
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

  void _unfavorite(BorderCheckpoint checkpoint) async {
    setState(() {
      _favorites.remove(checkpoint);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Column(
                  children: [
                    Text(
                      'My Favorite Checkpoints',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Keep track of your favorite border checkpoints',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _favorites.isEmpty
                  ? const EmptyStateWidget(passedText: 'favorite checkpoints')
                  : ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final checkpoint = _favorites[index];
                  return BorderCheckpointWidget(
                    border: checkpoint,
                    onToggleCallback: () => _unfavorite(checkpoint),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
