import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vehicle_verified/auth_screens/auth_selector_screen.dart';
import 'package:vehicle_verified/owner_screens/profile/edit_profile_screen.dart';
import 'package:vehicle_verified/owner_screens/profile/change_password_screen_authed.dart';
import 'package:vehicle_verified/owner_screens/profile/manage_phone_number_screen.dart';
import 'package:vehicle_verified/owner_screens/profile/notification_settings_screen.dart';
import 'package:vehicle_verified/owner_screens/profile/language_screen.dart';
import 'package:vehicle_verified/about_us_screen.dart';
import 'package:vehicle_verified/help_support_screen.dart';
import 'package:vehicle_verified/terms_privacy_screen.dart';
import 'package:vehicle_verified/themes/color.dart';

class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  // --- MOCK DATA ---
  // In a real app, this data would come from your user's profile in Firestore.
  final String userName = "Suraj Kumar";
  final String userEmail = "suraj.kumar@example.com";
  final String memberSince = "Joined Jan 2024";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColorOwner,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColorOwner,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 100.0),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 30),
          _buildSectionTitle('Account Settings'),
          _buildSettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                subtitle: 'Update your name, email, and photo',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                },
              ),
              _buildSettingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your login password',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreenAuthed()));
                },
              ),
              _buildSettingsTile(
                icon: Icons.phone_outlined,
                title: 'Manage Phone Number',
                subtitle: 'Update your registered mobile number',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ManagePhoneNumberScreen()));
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildSectionTitle('Preferences'),
          _buildSettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notification Settings',
                subtitle: 'Manage push and email alerts',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()));
                },
              ),
              _buildSettingsTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'English (US)',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageScreen()));
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          // --- NEW SECTION FOR OWNER ---
          _buildSectionTitle('More Information'),
          _buildSettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'FAQs and contact information',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
                },
              ),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'About Us',
                subtitle: 'Learn more about our mission',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen()));
                },
              ),
              _buildSettingsTile(
                icon: Icons.gavel_outlined,
                title: 'Terms & Privacy Policy',
                subtitle: 'Read our terms of service and privacy policy',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsPrivacyScreen()));
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  /// Builds the top section with the user's avatar and basic info.
  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 55,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 52,
            backgroundImage: AssetImage('assets/image/avatar.png'),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          userEmail,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        Text(
          memberSince,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  /// Builds a title for a section of settings.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  /// Builds a card to group a list of setting tiles.
  Widget _buildSettingsCard({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(children: children),
      ),
    );
  }

  /// Builds a single row (ListTile) for a setting option.
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primaryColorOwner),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600)) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  /// Builds the logout button at the bottom of the screen.
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        onPressed: () async{
          print("Logout button pressed...");
          await FirebaseAuth.instance.signOut();
          print("Firebase sign-out called. User should be null now.");
          // Navigate to the initial screen and clear the navigation stack.
          // Navigator.of(context).pushAndRemoveUntil(
          //   MaterialPageRoute(builder: (context) => const AuthSelectorScreen()),
          //       (Route<dynamic> route) => false,
          // );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}
