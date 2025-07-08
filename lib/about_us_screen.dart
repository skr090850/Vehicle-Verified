import 'package:flutter/material.dart';
import 'package:vehicle_verified/themes/color.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            icon: Icons.flag_circle,
            color: AppColors.primaryColorOwner,
            title: 'Our Mission',
            content:
            'To simplify vehicle document management and verification for everyone. We aim to create a seamless digital ecosystem where vehicle owners can store their documents securely and traffic officials can verify them instantly, making the roads safer and processes more efficient.',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            icon: Icons.visibility,
            color: Colors.green.shade700,
            title: 'Our Vision',
            content:
            'We envision a future with paperless vehicle documentation, reducing hassle and promoting environmental sustainability. Our platform is built on the principles of security, reliability, and user-friendliness.',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            icon: Icons.person_pin_circle_rounded,
            color: Colors.orange.shade800,
            title: 'Our Developer',
            content:
            'This application was proudly designed and developed by Suraj Kumar, a passionate developer dedicated to creating practical and user-friendly solutions.',
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Image.asset('assets/image/vehicle_verified_logo.png', height: 100),
            const SizedBox(height: 16),
            const Text(
              'VehicleVerified',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            Text(
              content,
              style: TextStyle(
                  fontSize: 16, color: Colors.grey.shade700, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
