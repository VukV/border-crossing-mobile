import 'package:border_crossing_mobile/screens/auth/login_screen.dart';
import 'package:border_crossing_mobile/screens/main/main_screen.dart';
import 'package:border_crossing_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BorderCrossingApp());
}

class BorderCrossingApp extends StatefulWidget {
  const BorderCrossingApp({super.key});

  @override
  State<BorderCrossingApp> createState() => _BorderCrossingAppState();
}

class _BorderCrossingAppState extends State<BorderCrossingApp> {
  bool _isLoggedIn = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool loggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[300],

      ),
      home: _isLoggedIn ? const MainScreen() : const LoginScreen(),
      routes: {
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}




