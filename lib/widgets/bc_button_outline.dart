import 'package:flutter/material.dart';

class BCButtonOutline extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Size? size;

  const BCButtonOutline({
    super.key,
    required this.text,
    required this.onPressed,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.deepPurple[400],
        side: BorderSide(
          color: Colors.deepPurple[400]!,
          width: 2.0,
        ),
        fixedSize: size,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
