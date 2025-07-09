import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehicle_verified/themes/color.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _expiryAlerts = true;
  bool _serviceReminders = true;
  bool _promotionalOffers = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()!.containsKey('notificationPrefs')) {
        final prefs = doc.data()!['notificationPrefs'] as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _expiryAlerts = prefs['expiryAlerts'] ?? true;
            _serviceReminders = prefs['serviceReminders'] ?? true;
            _promotionalOffers = prefs['promotionalOffers'] ?? false;
          });
        }
      }
    } catch (e) {
      print("Error loading settings: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({'notificationPrefs': {key: value}}, SetOptions(merge: true));
    } catch (e) {
      print("Error updating setting: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save setting: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColorOwner,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.backgroundColorOwner,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSwitchTile(
            title: 'Document Expiry Alerts',
            subtitle: 'Get notified before your documents expire',
            value: _expiryAlerts,
            onChanged: (val) {
              setState(() => _expiryAlerts = val);
              _updateSetting('expiryAlerts', val);
            },
          ),
          _buildSwitchTile(
            title: 'Service Reminders',
            subtitle: 'Receive reminders for upcoming vehicle services',
            value: _serviceReminders,
            onChanged: (val) {
              setState(() => _serviceReminders = val);
              _updateSetting('serviceReminders', val);
            },
          ),
          _buildSwitchTile(
            title: 'Promotional Offers',
            subtitle: 'Get updates on special offers and discounts',
            value: _promotionalOffers,
            onChanged: (val) {
              setState(() => _promotionalOffers = val);
              _updateSetting('promotionalOffers', val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryColorOwner,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
