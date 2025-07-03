import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About VehicleVerified', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/image/vehicle_verified_logo.png', height: 120),
            const SizedBox(height: 16),
            const Text(
              'VehicleVerified',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildInfoSection(
              'Our Mission',
              'To simplify vehicle document management and verification for everyone. We aim to create a seamless digital ecosystem where vehicle owners can store their documents securely and traffic officials can verify them instantly, making the roads safer and processes more efficient.',
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              'Our Vision',
              'We envision a future with paperless vehicle documentation, reducing hassle and promoting environmental sustainability. Our platform is built on the principles of security, reliability, and user-friendliness.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Divider(height: 20, thickness: 1),
        Text(
          content,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.5),
        ),
      ],
    );
  }
}
