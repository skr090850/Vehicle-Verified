import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehicle_verified/police_screens/manual_entry_screen.dart';
import 'package:vehicle_verified/police_screens/police_scanner_screen.dart';

class PoliceHomeScreen extends StatefulWidget {
  const PoliceHomeScreen({super.key});

  @override
  State<PoliceHomeScreen> createState() => _PoliceHomeScreenState();
}

class _PoliceHomeScreenState extends State<PoliceHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _officerName = "Loading...";
  bool _isLoading = true;

  // --- MOCK DATA for stats (can be replaced with real data later) ---
  final int scansToday = 28;
  final int issuesFound = 3;

  @override
  void initState() {
    super.initState();
    _fetchOfficerData();
  }

  /// Fetches the logged-in police officer's data from Firestore.
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
        title: const Text('Official Portal', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildWelcomeCard(),
            const SizedBox(height: 24),
            _buildStatsGrid(),
            const Spacer(),
            _buildPrimaryActionButton(
              context,
              label: 'Start Scanning',
              icon: Icons.qr_code_scanner,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PoliceScannerScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSecondaryActionButton(
              context,
              label: 'Enter Number Manually',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManualEntryScreen()),
                );
              },
            ),
            const SizedBox(height: 80), // To account for the floating nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/image/police_avatar.png'),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome Back,', style: TextStyle(color: Colors.black54)),
                Text(
                  _officerName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Scans Today',
            scansToday.toString(),
            Icons.document_scanner_outlined,
            Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Issues Found',
            issuesFound.toString(),
            Icons.warning_amber_rounded,
            Colors.orange.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white, size: 28),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade700,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
      ),
    );
  }

  Widget _buildSecondaryActionButton(BuildContext context, {required String label, required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red.shade700,
        side: BorderSide(color: Colors.red.shade700, width: 2),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label),
    );
  }
}
