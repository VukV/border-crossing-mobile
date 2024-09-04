import 'package:border_crossing_mobile/widgets/bc_button_outline.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  void test() {
    print('Test register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BCButtonOutline(
            text: 'Register test',
            onPressed: test
        ),
      ),
    );
  }
}