import 'package:border_crossing_mobile/models/border/border.dart';
import 'package:border_crossing_mobile/models/error.dart';
import 'package:border_crossing_mobile/services/border_service.dart';
import 'package:border_crossing_mobile/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
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
    return const Scaffold(
      body: Center(
        child: Text(
          'FAVORITES SCREEN',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
