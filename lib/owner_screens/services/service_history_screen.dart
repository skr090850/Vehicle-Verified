import 'package:flutter/material.dart';
import 'package:vehicle_verified/themes/color.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  // --- MOCK DATA ---
  // In a real app, this data would be fetched from Firestore.
  final List<String> _vehicles = [
    'All Vehicles',
    'Honda Activa - DL01AB1234',
    'Maruti Swift - BR01CD5678'
  ];
  String? _selectedVehicle;

  final List<Map<String, String>> _serviceHistory = [
    {
      "title": "General Maintenance",
      "date": "15 Jun 2024",
      "cost": "₹2,500",
      "workshop": "Reliable Auto Works",
      "vehicle": "Honda Activa - DL01AB1234",
    },
    {
      "title": "AC Gas Refill",
      "date": "02 Apr 2024",
      "cost": "₹1,200",
      "workshop": "Cool Car Care",
      "vehicle": "Maruti Swift - BR01CD5678",
    },
    {
      "title": "Insurance Renewed",
      "date": "20 Jan 2024",
      "cost": "₹8,500",
      "workshop": "Policy Online",
      "vehicle": "Maruti Swift - BR01CD5678",
    },
    {
      "title": "Oil Change",
      "date": "18 Dec 2023",
      "cost": "₹800",
      "workshop": "Speedy Service Center",
      "vehicle": "Honda Activa - DL01AB1234",
    }
  ];

  @override
  void initState() {
    super.initState();
    _selectedVehicle = _vehicles.first;
  }

  @override
  Widget build(BuildContext context) {
    // Filter the history based on the selected vehicle
    final filteredHistory = _selectedVehicle == 'All Vehicles'
        ? _serviceHistory
        : _serviceHistory
        .where((item) => item['vehicle'] == _selectedVehicle)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundColorOwner,
      appBar: AppBar(
        title: const Text('Service History', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColorOwner,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildVehicleSelector(),
          Expanded(
            child: filteredHistory.isEmpty
                ? const Center(
              child: Text(
                'No service history for this vehicle.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredHistory.length,
              itemBuilder: (context, index) {
                final item = filteredHistory[index];
                return _buildHistoryCard(
                  title: item['title']!,
                  date: item['date']!,
                  cost: item['cost']!,
                  workshop: item['workshop']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the dropdown menu to filter service history by vehicle.
  Widget _buildVehicleSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVehicle,
          isExpanded: true,
          icon: Icon(Icons.directions_car, color: AppColors.primaryColorOwner),
          onChanged: (String? newValue) {
            setState(() {
              _selectedVehicle = newValue;
            });
          },
          items: _vehicles.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Builds a card to display a single service history record.
  Widget _buildHistoryCard({
    required String title,
    required String date,
    required String cost,
    required String workshop,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  cost,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildDetailRow(Icons.store, 'Workshop', workshop),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.calendar_today, 'Date', date),
          ],
        ),
      ),
    );
  }

  /// Helper widget to build a detail row with an icon and text.
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 18),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
