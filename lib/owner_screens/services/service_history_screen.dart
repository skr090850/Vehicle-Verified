import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:vehicle_verified/themes/color.dart';

class ServiceHistoryItem {
  final String docId;
  final String vehicleId;
  final String title;
  final String date;
  final DateTime? serviceDateTime;
  final String cost;
  final String workshop;
  final String vehicleDisplay;
  final String status;
  final List<String> servicesPerformed;

  ServiceHistoryItem({
    required this.docId,
    required this.vehicleId,
    required this.title,
    required this.date,
    this.serviceDateTime,
    required this.cost,
    required this.workshop,
    required this.vehicleDisplay,
    required this.status,
    required this.servicesPerformed,
  });
}

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<List<ServiceHistoryItem>> _allServiceHistoryFuture;
  List<String> _vehiclesForFilter = ['All Vehicles'];
  String _selectedVehicleFilter = 'All Vehicles';

  @override
  void initState() {
    super.initState();
    _allServiceHistoryFuture = _fetchAllServiceHistories();
  }

  Future<List<ServiceHistoryItem>> _fetchAllServiceHistories() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    List<ServiceHistoryItem> allServices = [];
    List<String> vehicleTypes = ['All Vehicles'];

    final vehiclesSnapshot = await _firestore
        .collection('vehicles')
        .where('ownerID', isEqualTo: user.uid)
        .get();

    for (var vehicleDoc in vehiclesSnapshot.docs) {
      final vehicleData = vehicleDoc.data();
      final vehicleDisplay =
          '${vehicleData['make'] ?? ''} ${vehicleData['model'] ?? ''} - ${vehicleData['registrationNumber'] ?? 'N/A'}';

      vehicleTypes.add(vehicleDisplay);

      final historySnapshot = await vehicleDoc.reference
          .collection('serviceHistory')
          .orderBy('serviceDate', descending: true)
          .get();

      for (var historyDoc in historySnapshot.docs) {
        final historyData = historyDoc.data();
        final serviceDate = (historyData['serviceDate'] as Timestamp?)?.toDate();
        final costValue = historyData['cost'];
        String costString = 'Pending';
        if (costValue is num) {
          costString = '₹${costValue.toStringAsFixed(2)}';
        }

        allServices.add(
          ServiceHistoryItem(
            docId: historyDoc.id,
            vehicleId: vehicleDoc.id,
            title: historyData['serviceType'] ?? 'Unknown Service',
            date: serviceDate != null ? DateFormat.yMMMd().format(serviceDate) : 'N/A',
            serviceDateTime: serviceDate,
            cost: costString,
            workshop: historyData['workshop'] ?? 'Pending',
            vehicleDisplay: vehicleDisplay,
            status: historyData['status'] ?? 'Unknown',
            servicesPerformed: List<String>.from(historyData['servicesPerformed'] ?? []),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _vehiclesForFilter = vehicleTypes;
      });
    }

    return allServices;
  }

  Future<void> _updateServiceStatus(ServiceHistoryItem item, String newStatus) async {
    try {
      await _firestore
          .collection('vehicles')
          .doc(item.vehicleId)
          .collection('serviceHistory')
          .doc(item.docId)
          .update({'status': newStatus});

      setState(() {
        _allServiceHistoryFuture = _fetchAllServiceHistories();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service status updated!'), backgroundColor: Colors.green),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  void _showCompletionDialog(ServiceHistoryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Service Completion'),
          content: const Text('Please confirm that the service has been completed. You can also rate your experience.'),
          actions: [
            TextButton(
              child: const Text('Bad Service'),
              onPressed: () {
                Navigator.of(context).pop();
                _updateServiceStatus(item, 'Completed (Bad)');
              },
            ),
            TextButton(
              child: const Text('Good Service'),
              onPressed: () {
                Navigator.of(context).pop();
                _updateServiceStatus(item, 'Completed (Good)');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: FutureBuilder<List<ServiceHistoryItem>>(
              future: _allServiceHistoryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No service history found.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final filteredHistory = _selectedVehicleFilter == 'All Vehicles'
                    ? snapshot.data!
                    : snapshot.data!
                    .where((item) => item.vehicleDisplay == _selectedVehicleFilter)
                    .toList();

                if (filteredHistory.isEmpty) {
                  return const Center(
                    child: Text(
                      'No service history for this vehicle.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredHistory.length,
                  itemBuilder: (context, index) {
                    final item = filteredHistory[index];
                    return _buildHistoryCard(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
          value: _selectedVehicleFilter,
          isExpanded: true,
          icon: Icon(Icons.directions_car, color: AppColors.primaryColorOwner),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedVehicleFilter = newValue;
              });
            }
          },
          items: _vehiclesForFilter.map<DropdownMenuItem<String>>((String value) {
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

  Widget _buildHistoryCard(ServiceHistoryItem item) {
    Color statusColor;
    bool showCompletionButton = false;

    if (item.status == 'Booked' && item.serviceDateTime != null && item.serviceDateTime!.isBefore(DateTime.now())) {
      statusColor = Colors.orange;
      showCompletionButton = true;
    } else if (item.status.contains('Completed')) {
      statusColor = Colors.green;
    } else if (item.status == 'Booked') {
      statusColor = Colors.blue;
    } else {
      statusColor = Colors.grey;
    }

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
            if (_selectedVehicleFilter == 'All Vehicles') ...[
              Row(
                children: [
                  Icon(Icons.directions_car, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.vehicleDisplay,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  item.cost,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            if (item.servicesPerformed.isNotEmpty) ...[
              Text('Services Performed:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              const SizedBox(height: 4),
              ...item.servicesPerformed.map((service) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                child: Text('• $service'),
              )).toList(),
              const Divider(height: 20),
            ],
            _buildDetailRow(Icons.store, 'Workshop', item.workshop),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.calendar_today, 'Date', item.date),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.info_outline, 'Status', item.status),
            if (showCompletionButton) ...[
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => _showCompletionDialog(item),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Confirm Completion', style: TextStyle(color: Colors.white)),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

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
