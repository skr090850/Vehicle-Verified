import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Date formatting ke liye
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

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  // --- Firebase Instances ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- State variables to hold user data ---
  String _userName = "Loading...";
  String _userEmail = "Loading...";
  String _memberSince = "";
  String? _profileImageUrl; // To hold the image URL
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Fetches user data from Firestore and updates the state.
  Future<void> _fetchUserData() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _userName = "Guest User";
          _userEmail = "Not logged in";
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && mounted) {
        final data = userDoc.data() as Map<String, dynamic>;
        final Timestamp? createdAt = data['createdAt'];

        setState(() {
          _userName = data['name'] ?? 'No Name';
          _userEmail = data['email'] ?? 'No Email';
          _profileImageUrl = data['profileImageUrl']; // Fetch the image URL
          if (createdAt != null) {
            _memberSince =
            "Joined ${DateFormat.yMMMM().format(createdAt.toDate())}";
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = "Error";
          _userEmail = "Could not fetch data";
          _isLoading = false;
        });
      }
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchUserData, // Allows pull-to-refresh
        child: ListView(
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
                  onTap: () async {
                    // Navigate and wait for a potential update
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const EditProfileScreen()));
                    // Refresh data after returning from edit screen
                    _fetchUserData();
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your login password',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const ChangePasswordScreenAuthed()));
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.phone_outlined,
                  title: 'Manage Phone Number',
                  subtitle: 'Update your registered mobile number',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const ManagePhoneNumberScreen()));
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const NotificationSettingsScreen()));
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'English (US)',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LanguageScreen()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('More Information'),
            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'FAQs and contact information',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const HelpSupportScreen()));
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  subtitle: 'Learn more about our mission',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AboutUsScreen()));
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.gavel_outlined,
                  title: 'Terms & Privacy Policy',
                  subtitle: 'Read our terms of service and privacy policy',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const TermsPrivacyScreen()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  /// Builds the top section with the user's avatar and basic info.
  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 52,
            backgroundColor: AppColors.primaryColorOwner.withOpacity(0.1),
            // --- UPDATED: Dynamic image loading ---
            backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                ? NetworkImage(_profileImageUrl!)
                : null,
            child: (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                ? const Icon(
              Icons.person,
              size: 50,
              color: AppColors.primaryColorOwner,
            )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _userName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _userEmail,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        Text(
          _memberSince,
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
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600))
          : null,
      trailing:
      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  /// Builds the logout button at the bottom of the screen.
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthSelectorScreen()),
                  (Route<dynamic> route) => false,
            );
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}
