import 'package:flutter/material.dart';
import 'package:vehicle_verified/themes/color.dart';

class ManagePhoneNumberScreen extends StatefulWidget {
  const ManagePhoneNumberScreen({super.key});

  @override
  State<ManagePhoneNumberScreen> createState() => _ManagePhoneNumberScreenState();
}

class _ManagePhoneNumberScreenState extends State<ManagePhoneNumberScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Phone Number', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColorOwner,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.backgroundColorOwner,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Your current registered phone number is:',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              '+91 7274960865', // Mock data
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              icon: const Icon(Icons.change_circle_outlined),
              label: const Text('Change Phone Number'),
              onPressed: () {
                // TODO: Implement OTP flow to change number
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColorOwner,
                side: const BorderSide(color: AppColors.primaryColorOwner),
                minimumSize: const Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }
}
