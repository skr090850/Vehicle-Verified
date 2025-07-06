import 'package:flutter/material.dart';
import 'package:vehicle_verified/auth_screens/login_screen.dart';
import 'package:vehicle_verified/themes/color.dart';

class AuthSelectorScreen extends StatelessWidget {
  const AuthSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '\nVehicle Verified',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColorOwner,
          ),
        ),
        backgroundColor: AppColors.backgroundColorFirst,
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundColorFirst,
      body: SafeArea(
        child: Center(
          // SingleChildScrollView ka istemaal taaki content scroll ho sake
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Pehle wala saara content wapas add kar diya gaya hai
                Image.asset('assets/image/suv.png', height: 200, width: 200),
                const Text(
                  "\nTake control of your vehicle's\npaperwork effortlessly.\nNavigate the road ahead with confidence,\nsupported by our app.\n",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.verified_user,
                  size: 80.0,
                  color: Colors.green.shade700,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please select your role to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                _buildRoleButton(
                  context: context,
                  icon: Icons.directions_car,
                  title: 'Vehicle Owner',
                  subtitle: 'Manage your vehicle documents.',
                  color: AppColors.primaryColorOwner,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(userRole: 'owner'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildRoleButton(
                  context: context,
                  icon: Icons.local_police,
                  title: 'Traffic Official',
                  subtitle: 'Scan & verify documents.',
                  color: Colors.red.shade700,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(userRole: 'police'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Role selection button banane ke liye helper method
  Widget _buildRoleButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        elevation: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
