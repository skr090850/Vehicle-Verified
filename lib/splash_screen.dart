import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vehicle_verified/themes/color.dart';
import 'dart:async';
import 'package:vehicle_verified/auth_screens/auth_wrapper.dart'; // FIX: AuthWrapper ko import karein

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), _navigate);
  }

  void _navigate() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return Scaffold(
      backgroundColor: AppColors.backgroundColorFirst,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/image/vehicle_verified_logo.png', height: 250, width: 250,),
            const SizedBox(height: 24.0),
            Text(
              'Vehicle Verified',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              'Your Documents, Secured & Verified.',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 80.0),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColorOwner),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }
}
