import 'package:flutter/material.dart';

class BCButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Size? size;

  const BCButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.grey[200],
        backgroundColor: Colors.deepPurple[400],
        fixedSize: size,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}
