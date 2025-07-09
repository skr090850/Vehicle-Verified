import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehicle_verified/themes/color.dart';

class ManagePhoneNumberScreen extends StatefulWidget {
  const ManagePhoneNumberScreen({super.key});

  @override
  State<ManagePhoneNumberScreen> createState() =>
      _ManagePhoneNumberScreenState();
}

class _ManagePhoneNumberScreenState extends State<ManagePhoneNumberScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _phoneNumber = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserPhoneNumber();
  }

  Future<void> _fetchUserPhoneNumber() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _phoneNumber = 'Not available';
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
          _phoneNumber = data['phone'] ?? 'Not provided';
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _phoneNumber = 'No data found';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _phoneNumber = 'Error fetching data';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Phone Number',
            style: TextStyle(color: Colors.white)),
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
            _isLoading
                ? const CircularProgressIndicator()
                : Text(
              _phoneNumber,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              icon: const Icon(Icons.change_circle_outlined),
              label: const Text('Change Phone Number'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This feature is coming soon!')),
                );
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
