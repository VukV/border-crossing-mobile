import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:border_crossing_mobile/widgets/bc_button.dart';
import 'package:border_crossing_mobile/screens/auth/register_screen.dart';
import '../../models/error.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final email = emailController.text;
      final password = passwordController.text;

      final user = await _authService.login(email, password);
      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      if (e is BCError) {
        _showSnackbar(e.message);
      } else {
        _showSnackbar('An unknown error occurred.');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToRegisterScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100),
              const Center(
                child: Icon(
                  Icons.share_location,
                  size: 100,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : BCButton(
                text: 'Login',
                onPressed: _login,
              ),
              const Spacer(),
              Center(
                child: Text.rich(
                  style: const TextStyle(fontSize: 16),
                  TextSpan(
                    text: "Don't have an account? ",
                    children: [
                      TextSpan(
                        text: 'Register now.',
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.deepPurple,
                          fontWeight: FontWeight.bold
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            navigateToRegisterScreen(context);
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}