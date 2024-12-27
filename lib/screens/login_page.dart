import 'dart:convert';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:easibite/screens/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_main.dart';
import 'onboarding_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String errorMessage = '';
  UserProfile? _user;
  Credentials? _credentials;
  bool _isLoading = false;

  late Auth0 auth0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final String correctEmail = "user@easibite.com";
  final String correctPassword = "password123";

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email == correctEmail && password == correctPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      setState(() {
        _isLoading = false;
      });

      // Call onboarding completion check
      _checkOnboardingCompletion();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email or password")),
      );
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });
      auth0 = Auth0(
        'easibites.us.auth0.com',
        'bWF1PuPqEXqmIlsnl7ybbsFzUaWByFze',
      );

      final credentials = await auth0.webAuthentication().login(useHTTPS: true);
      if (credentials == null) {
        print("Error: Credentials are null.");
        return;
      }

      setState(() {
        _credentials = credentials;
        _user = credentials.user;
      });
      final prefs = await SharedPreferences.getInstance();

      await _saveUserDataToLocal();
      await prefs.setBool('isLoggedIn', true);
      setState(() {
        _isLoading = false;
      });

      _checkOnboardingCompletion();
    } catch (e) {
      print('Error during login: $e');
      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ErrorPage(
            errorMessage: "Error during login: $e",
            onRetry: () => _handleGoogleSignIn(context),
          ),
        ),
      );
    }
  }

  Future<void> _saveUserDataToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode({
      'name': _user?.name ?? '',
      'email': _user?.email ?? '',
      'profileUrl': _user?.profileUrl?.toString() ?? '',
      'picture': _user?.pictureUrl?.toString() ?? '',
      'nickname': _user?.nickname ?? '',
      'givenName': _user?.givenName ?? '',
      'familyName': _user?.familyName ?? '',
      'locale': _user?.locale ?? '',
      'sub': _user?.sub ?? '',
    });

    await prefs.setString('userProfile', userJson);
    await prefs.setBool('isLoggedIn', true);
    print("User data saved locally");
  }

  Future<void> _checkOnboardingCompletion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isOnboardingComplete = prefs.getBool('isOnboarded') ?? false;

      if (isOnboardingComplete) {
        if (_user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeMain(user: _user!)),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen(user: _user)),
        );
      }
    } catch (e) {
      print("Error checking onboarding completion: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingScreen()
        : EasiBiteUI(
      onLoginPressed: _handleGoogleSignIn,
      emailController: _emailController,
      passwordController: _passwordController,
      loginFunction: _login,
    );
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );
  }
}

class EasiBiteUI extends StatelessWidget {
  final Function(BuildContext) onLoginPressed;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback loginFunction;

  const EasiBiteUI({
    Key? key,
    required this.onLoginPressed,
    required this.emailController,
    required this.passwordController,
    required this.loginFunction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo and text components
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: loginFunction,
                    child: const Text("Login"),
                  ),
                ],
              ),
            ),
            // Buttons
            // Uncommented buttons
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     OutlinedButton(
            //       onPressed: () {},
            //       child: const Text("Log In"),
            //     ),
            //     const SizedBox(width: 20),
            //     ElevatedButton(
            //       onPressed: () {},
            //       child: const Text("Sign Up"),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

class ErrorPage extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorPage({required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Error")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
