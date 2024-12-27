import 'package:flutter/material.dart';

import 'screens/launch_page.dart';

// import 'package:firebase_core/firebase_core.dart';


void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  // try {
  //   await Firebase.initializeApp();
  //   print("Firebase initialized successfully!");
  // } catch (e) {
  //   print("Firebase initialization failed: $e");
  // }
  runApp(const Easibite());
}

class Easibite extends StatelessWidget {
  const Easibite({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easibite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LaunchPage(),
    );
  }
}
