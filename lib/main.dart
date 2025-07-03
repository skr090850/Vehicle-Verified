import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vehicle_verified/splash_screen.dart'; // SplashScreen ko import karein
import 'firebase_options.dart';

void main() async {
  // Yeh lines Firebase ko shuru karne ke liye zaroori hain
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Verified',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
