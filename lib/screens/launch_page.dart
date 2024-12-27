import 'dart:convert';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:easibite/screens/home_main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/bottom_nav_bar.dart';
import 'login_page.dart';
import 'onboarding_page.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({Key? key}) : super(key: key);

  @override
  _LaunchPageState createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  UserProfile? _user;  // Declare _user as a member of the state

  @override
  void initState() {
    super.initState();
    _getInitialPage();
  }

  // Method to load user data
  Future<void> _getInitialPage() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('userProfile');

    if (userJson != null) {
      final userMap = jsonDecode(userJson);
      setState(() {
        _user = UserProfile(
          name: userMap['name'],
          email: userMap['email'],
          profileUrl: userMap['profileUrl'] != null ? Uri.parse(userMap['profileUrl']) : null,
          pictureUrl: userMap['picture'] != null ? Uri.parse(userMap['picture']) : null,
          nickname: userMap['nickname'],
          givenName: userMap['givenName'],
          familyName: userMap['familyName'],
          locale: userMap['locale'],
          sub: userMap['sub'],
        );
      });
    }

    // Proceed to next action
    _takeAction();
  }

  // Your method for handling login and page navigation
  Future<void> _takeAction() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final isOnboarded = prefs.getBool('isOnboarded') ?? false;

    if (isLoggedIn) {
      if (isOnboarded) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeMain(user: _user!)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen(user: _user!)),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading spinner while user data is loading
    return Scaffold(
      body: Center(
        child: _user == null
            ? const CircularProgressIndicator()
            : const Text('User Loaded!'), // Replace with actual UI
      ),
    );
  }
}
