import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vehicle_verified/auth_screens/auth_selector_screen.dart';
import 'package:vehicle_verified/about_us_screen.dart';
import 'package:vehicle_verified/help_support_screen.dart';
import 'package:vehicle_verified/terms_privacy_screen.dart';

class PoliceProfileScreen extends StatefulWidget {
  const PoliceProfileScreen({super.key});

  @override
  State<PoliceProfileScreen> createState() => _PoliceProfileScreenState();
}

class _PoliceProfileScreenState extends State<PoliceProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _officerName = "Loading...";
  String _officialId = "Loading...";
  String _officerEmail = "Loading...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOfficerData();
  }

  Future<void> _fetchOfficerData() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _officerName = "Guest";
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
        setState(() {
          _officerName = data['name'] ?? 'Officer';
          _officialId = data['officialId'] ?? 'N/A';
          _officerEmail = data['email'] ?? 'No email provided';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _officerName = "Error";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text('Official Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchOfficerData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildMoreOptionsCard(context),
            const SizedBox(height: 24),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 52,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/image/police_avatar.png'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _officerName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _officerEmail,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.badge_outlined, 'Official ID', _officialId),
            const Divider(height: 24),
            _buildInfoRow(Icons.security_outlined, 'Status', 'Active & Verified'),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOptionsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildOptionTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
            },
          ),
          const Divider(height: 1),
          _buildOptionTile(
            context,
            icon: Icons.info_outline,
            title: 'About Us',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutUsScreen()));
            },
          ),
          const Divider(height: 1),
          _buildOptionTile(
            context,
            icon: Icons.gavel_outlined,
            title: 'Terms & Privacy Policy',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TermsPrivacyScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.red.shade700),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context,
      {required IconData icon,
        required String title,
        required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout, color: Colors.white),
      label: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16)),
      onPressed: () async {
        await _auth.signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthSelectorScreen()),
                (Route<dynamic> route) => false,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade700,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
