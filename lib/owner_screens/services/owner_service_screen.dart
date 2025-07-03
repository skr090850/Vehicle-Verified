import 'package:flutter/material.dart';
import 'package:vehicle_verified/owner_screens/services/general_maintenance_screen.dart';
import 'package:vehicle_verified/owner_screens/services/ac_cooling_repair_screen.dart';
import 'package:vehicle_verified/owner_screens/services/insurance_renewal_screen.dart';
import 'package:vehicle_verified/owner_screens/services/denting_painting_screen.dart';
import 'package:vehicle_verified/owner_screens/services/deep_cleaning_screen.dart';
import 'package:vehicle_verified/owner_screens/services/service_history_screen.dart';
import 'package:vehicle_verified/themes/color.dart';

class OwnerServiceScreen extends StatelessWidget {
  const OwnerServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Service data with navigation targets
    final List<Map<String, dynamic>> services = [
      {
        "icon": Icons.build_circle,
        "title": "General Maintenance",
        "description": "Full check-up, oil change, and filter replacement.",
        "color": Colors.blue.shade700,
        "target": const GeneralMaintenanceScreen(),
      },
      {
        "icon": Icons.ac_unit,
        "title": "AC & Cooling Repair",
        "description": "Gas refill, compressor check, and coolant top-up.",
        "color": Colors.cyan.shade600,
        "target": const AcCoolingRepairScreen(),
      },
      {
        "icon": Icons.shield,
        "title": "Insurance Renewal",
        "description": "Get quotes and renew your vehicle's insurance policy.",
        "color": Colors.green.shade700,
        "target": const InsuranceRenewalScreen(),
      },
      {
        "icon": Icons.format_paint,
        "title": "Denting & Painting",
        "description": "Remove dents, scratches, and apply a fresh coat of paint.",
        "color": Colors.orange.shade800,
        "target": const DentingPaintingScreen(),
      },
      {
        "icon": Icons.cleaning_services,
        "title": "Deep Cleaning",
        "description": "Interior vacuum, dashboard polish, and exterior wash.",
        "color": Colors.purple.shade600,
        "target": const DeepCleaningScreen(),
      }
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColorOwner,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColorOwner,
        title: const Text('Book a Service', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Service History',
            onPressed: () {
              // Navigate to the separate ServiceHistoryScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ServiceHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceCard(
            context: context,
            icon: service['icon'],
            title: service['title'],
            description: service['description'],
            color: service['color'],
            targetScreen: service['target'],
          );
        },
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Widget targetScreen,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
