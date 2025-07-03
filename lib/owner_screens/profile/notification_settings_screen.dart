import 'package:flutter/material.dart';
import 'package:vehicle_verified/themes/color.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _expiryAlerts = true;
  bool _serviceReminders = true;
  bool _promotionalOffers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColorOwner,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.backgroundColorOwner,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSwitchTile(
            title: 'Document Expiry Alerts',
            subtitle: 'Get notified before your documents expire',
            value: _expiryAlerts,
            onChanged: (val) => setState(() => _expiryAlerts = val),
          ),
          _buildSwitchTile(
            title: 'Service Reminders',
            subtitle: 'Receive reminders for upcoming vehicle services',
            value: _serviceReminders,
            onChanged: (val) => setState(() => _serviceReminders = val),
          ),
          _buildSwitchTile(
            title: 'Promotional Offers',
            subtitle: 'Get updates on special offers and discounts',
            value: _promotionalOffers,
            onChanged: (val) => setState(() => _promotionalOffers = val),
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
