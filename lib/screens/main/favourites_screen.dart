import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // TODO
  // final BorderService _borderService = BorderService();
  //
  // void _toggleFavorite(BorderCheckpoint checkpoint) async {
  //   setState(() {
  //     checkpoint.favorite = !checkpoint.favorite; // Toggle favorite status
  //   });
  //
  //   // Here you would typically also send the updated status to your backend
  // }

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
