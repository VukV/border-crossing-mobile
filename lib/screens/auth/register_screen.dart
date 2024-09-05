import 'package:border_crossing_mobile/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import '../../models/error.dart';
import '../../services/auth_service.dart';
import '../../widgets/bc_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;

  Future<void> _register() async {
    setState(() {
      isLoading = true;
    });

    try {
      final email = emailController.text;
      final password = passwordController.text;
      final repeatPassword = repeatPasswordController.text;
      final firstName = firstNameController.text;
      final lastName = lastNameController.text;

      await _authService.register(email, password, repeatPassword, firstName, lastName);
      if (mounted) {
        SnackbarUtils.showSnackbar(context, 'Registered successfully. You may login.', Colors.deepPurple[400]);
        Navigator.pushReplacementNamed(context, '/login');
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
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.deepPurple,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Icon(
                  Icons.person_add,
                  size: 100,
                  color: Colors.deepPurple,
                ),
              ),
              Text(
                'Register a new account',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800]
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: repeatPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Repeat Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32.0),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : BCButton(
                text: 'Register',
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}