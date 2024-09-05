import 'package:flutter/material.dart';

class BorderTimesScreen extends StatelessWidget {
  const BorderTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'BORDER TIMES SCREEN',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
