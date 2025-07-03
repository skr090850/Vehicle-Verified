import 'package:flutter/material.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Legal Information', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey.shade800,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Terms of Service'),
              Tab(text: 'Privacy Policy'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Text(
                // --- Placeholder Text ---
                'Please replace this with your actual Terms of Service.\n\n'
                    '1. Introduction\nWelcome to VehicleVerified. By using our app, you agree to these terms...\n\n'
                    '2. User Accounts\nYou are responsible for maintaining the confidentiality of your account and password...\n\n'
                    '3. Prohibited Activities\nYou may not use the app for any illegal or unauthorized purpose...',
                style: TextStyle(height: 1.5),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Text(
                // --- Placeholder Text ---
                'Please replace this with your actual Privacy Policy.\n\n'
                    '1. Information We Collect\nWe collect information you provide directly to us, such as when you create an account...\n\n'
                    '2. How We Use Your Information\nWe use the information we collect to operate, maintain, and provide you with the features and functionality of the app...\n\n'
                    '3. Sharing of Your Information\nWe may share your information with third-party vendors and other service providers...',
                style: TextStyle(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
