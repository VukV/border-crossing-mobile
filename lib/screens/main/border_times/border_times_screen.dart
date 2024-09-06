import 'package:border_crossing_mobile/models/border/border.dart';
import 'package:flutter/material.dart';

class BorderTimesScreen extends StatefulWidget {
  final BorderCheckpoint border;

  const BorderTimesScreen({super.key, required this.border});

  @override
  State<BorderTimesScreen> createState() => _BorderTimesScreenState();
}

class _BorderTimesScreenState extends State<BorderTimesScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          widget.border.name,
          style: const TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: const Center(
        child: Text('Border Times Screen'),
      ),
    );
  }
}
