import 'dart:convert';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:easibite/screens/auth_service.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_main.dart';
import 'onboarding_page.dart';

import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

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


  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });
      // Initialize Auth0 instance
      auth0 = Auth0(
        'easibites.us.auth0.com',
        'bWF1PuPqEXqmIlsnl7ybbsFzUaWByFze',
      );

      // Perform login
      final credentials = await auth0.webAuthentication().login(useHTTPS: true);

      if (credentials == null) {
        print("Error: Credentials are null.");
        return;
      }

      // Update state
      setState(() {
        _credentials = credentials;
        _user = credentials.user;
      });
      final prefs = await SharedPreferences.getInstance();

      // Set the flags to true
      await _saveUserDataToLocal();
      await prefs.setBool('isLoggedIn', true);
      setState(() {
        _isLoading = false;
      });

      // Call onboarding completion check
      _checkOnboardingCompletion();
    } catch (e) {
      print('Error during login: $e');
      setState(() {
        _isLoading = false;
      });

      // Navigate to error page
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

    // Convert the entire user profile to JSON
    final userJson = jsonEncode({
      'name': _user?.name ?? '',
      'email': _user?.email ?? '',
      'profileUrl': _user?.profileUrl?.toString() ?? '',  // Convert Uri to String
      'picture': _user?.pictureUrl?.toString() ?? '',    // Convert Uri to String
      'nickname': _user?.nickname ?? '',
      'givenName': _user?.givenName ?? '',
      'familyName': _user?.familyName ?? '',
      'locale': _user?.locale ?? '',
      'sub': _user?.sub ?? '',  // The unique user identifier (usually available)
      // You can add any other fields that are part of the UserProfile
    });

    // Save the JSON string in SharedPreferences
    await prefs.setString('userProfile', userJson);
    await prefs.setBool('isLoggedIn', true);  // Mark the user as logged in

    print("User data saved locally");
  }


  Future<void> _checkOnboardingCompletion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isOnboardingComplete = prefs.getBool('isOnboarded') ?? false;


      if (isOnboardingComplete) {
        final data = prefs.getString('userPreferences');
        if (data != null) {
          print("Decoded preferences: $data");
        }

        // Check if _user is authenticated before navigating
        if (_user != null) {
          print("ss1");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeMain(user: _user!)), // Pass _user to HomeMain
          );
        } else {
          print("User not authenticated yet.");
        }
      }
      else{
        print("ss2");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen(user: _user)), // Pass _user to HomeMain
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
        : EasiBiteUI(onLoginPressed: _handleGoogleSignIn); // Show loading first, then the main UI
  }
}
// Loading Screen Widget
class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      ),
    );
  }
}
// Main UI
class EasiBiteUI extends StatelessWidget {
  final Function(BuildContext) onLoginPressed;

  const EasiBiteUI({Key? key, required this.onLoginPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      "EasiBite",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -10,
                    right: -10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),

            // Welcome Text
            Text(
              "Welcome to",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              "EasiBite",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 10),

            // Subtitle
            Text(
              "Let’s personalize your dining experience",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 40),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Log In Button
                OutlinedButton(
                  onPressed: () {
                    onLoginPressed(context);
                    // AuthService().signInWithGoogle();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.orange),
                    padding:
                    EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Log In",
                    style: TextStyle(color: Colors.orange, fontSize: 16),
                  ),
                ),
                SizedBox(width: 20),

                // Sign Up Button
                ElevatedButton(
                  onPressed: () {
                    // Handle Sign Up
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding:
                    EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
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
