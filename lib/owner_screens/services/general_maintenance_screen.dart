import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vehicle_verified/themes/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceItem {
  final String name;
  final Map<String, double> costs;

  ServiceItem({required this.name, required this.costs});
}

class GeneralMaintenanceScreen extends StatefulWidget {
  const GeneralMaintenanceScreen({super.key});

  @override
  State<GeneralMaintenanceScreen> createState() =>
      _GeneralMaintenanceScreenState();
}

class _GeneralMaintenanceScreenState extends State<GeneralMaintenanceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<List<Map<String, dynamic>>> _vehiclesFuture;
  String? _selectedVehicleId;
  Map<String, dynamic>? _selectedVehicleData;
  double _totalCost = 0.0;
  final List<String> _includedServices = [
    'Engine Oil Replacement',
    'Oil Filter Replacement',
    'Air Filter Cleaning',
    'Coolant Top-up',
    'Brake Fluid Check & Top-up',
    'Battery Checkup',
    'Complete Electrical Checkup',
    'Chain Lubrication & Adjustment'
  ];

  final List<ServiceItem> _availableServices = [
    ServiceItem(name: 'Engine Oil Replacement', costs: {'2-Wheeler': 350.00, '4-Wheeler': 800.00}),
    ServiceItem(name: 'Oil Filter Replacement', costs: {'2-Wheeler': 150.00, '4-Wheeler': 450.00}),
    ServiceItem(name: 'Air Filter Cleaning', costs: {'2-Wheeler': 50.00, '4-Wheeler': 150.00}),
    ServiceItem(name: 'Air Filter Replacement', costs: {'2-Wheeler': 250.00, '4-Wheeler': 600.00}),
    ServiceItem(name: 'Coolant Top-up', costs: {'2-Wheeler': 100.00, '4-Wheeler': 250.00}),
    ServiceItem(name: 'Brake Fluid Check & Top-up', costs: {'2-Wheeler': 80.00, '4-Wheeler': 200.00}),
    ServiceItem(name: 'Battery Checkup', costs: {'2-Wheeler': 100.00, '4-Wheeler': 200.00}),
    ServiceItem(name: 'Chain Lubrication & Adjustment', costs: {'2-Wheeler': 120.00, '4-Wheeler': 0}),
  ];

  final Set<String> _selectedServices = {};

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = _fetchUserVehicles();
  }

  Future<List<Map<String, dynamic>>> _fetchUserVehicles() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('vehicles')
        .where('ownerID', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final displayString =
          '${data['make'] ?? ''} ${data['model'] ?? ''} - ${data['registrationNumber'] ?? 'N/A'}';

      // Determine category for costing
      String category = '4-Wheeler';
      if (['Scooty', 'Motorcycle'].contains(data['vehicleType'])) {
        category = '2-Wheeler';
      }

      return {
        'id': doc.id,
        'display': displayString,
        'category': category,
      };
    }).toList();
  }

  void _calculateTotalCost() {
    double total = 0.0;
    if (_selectedVehicleData == null) {
      setState(() { _totalCost = 0.0; });
      return;
    }

    final vehicleCategory = _selectedVehicleData!['category'];

    for (var serviceName in _selectedServices) {
      final service = _availableServices.firstWhere((s) => s.name == serviceName);
      total += service.costs[vehicleCategory] ?? 0;
    }

    setState(() {
      _totalCost = total;
    });
  }

  Future<void> _bookAppointment() async {
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a vehicle.')));
      return;
    }
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one service.')));
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date and time.')));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final appointmentDateTime = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _selectedTime!.hour, _selectedTime!.minute,
      );

      await _firestore
          .collection('vehicles')
          .doc(_selectedVehicleId)
          .collection('serviceHistory')
          .add({
        'serviceType': 'Custom Maintenance',
        'servicesPerformed': _selectedServices.toList(),
        'serviceDate': Timestamp.fromDate(appointmentDateTime),
        'notes': _notesController.text.trim(),
        'status': 'Booked',
        'cost': _totalCost,
        'workshop': 'Verified Auto Center',
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book appointment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && mounted) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColorOwner,
      appBar: AppBar(
        title: const Text('General Maintenance', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColorOwner,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _vehiclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching vehicles: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No vehicles found.'));
          }

          final vehicles = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Package Includes',
                  content: _buildInclusionsList(),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Schedule Your Appointment',
                  content: _buildSchedulingForm(vehicles),
                ),
                const SizedBox(height: 24),
                if (_selectedVehicleId != null)
                  _buildSection(
                    title: 'Select Services',
                    content: _buildServicesList(),
                  ),
                const SizedBox(height: 24),
                if (_totalCost > 0)
                  _buildSection(
                    title: 'Total Cost',
                    content: _buildCostDisplayCard(),
                  ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Additional Notes',
                  content: _buildNotesField(),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBookingButton(),
    );
  }

  Widget _buildServicesList() {
    final vehicleCategory = _selectedVehicleData?['category'] ?? '4-Wheeler';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: _availableServices.map((service) {
          final cost = service.costs[vehicleCategory] ?? 0;
          if (cost == 0) return const SizedBox.shrink();

          return CheckboxListTile(
            title: Text(service.name),
            subtitle: Text('₹${cost.toStringAsFixed(2)}'),
            value: _selectedServices.contains(service.name),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedServices.add(service.name);
                } else {
                  _selectedServices.remove(service.name);
                }
                _calculateTotalCost();
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2)
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.build_circle, color: AppColors.primaryColorOwner, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Periodic Maintenance Service',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Customize your service package below.',
                  style: TextStyle(color: Colors.black54),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildCostDisplayCard() {
    return Card(
      elevation: 2,
      color: AppColors.primaryColorOwner.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text(
              '₹${_totalCost.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColorOwner,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInclusionsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: _includedServices
              .map((service) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(service)),
              ],
            ),
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSchedulingForm(List<Map<String, dynamic>> vehicles) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedVehicleId,
              hint: const Text('Select your vehicle'),
              decoration: const InputDecoration(
                labelText: 'Select Vehicle',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              items: vehicles
                  .map((vehicle) => DropdownMenuItem(
                value: vehicle['id'] as String,
                child: Text(vehicle['display'] as String),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVehicleId = value;
                  _selectedVehicleData = vehicles.firstWhere((v) => v['id'] == value);
                  _selectedServices.clear();
                  _calculateTotalCost();
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                labelText: 'Preferred Date',
                hintText: _selectedDate == null
                    ? 'Select a date'
                    : DateFormat('dd MMM, yyyy').format(_selectedDate!),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              onTap: _pickTime,
              decoration: InputDecoration(
                labelText: 'Preferred Time',
                hintText: _selectedTime == null
                    ? 'Select a time slot'
                    : _selectedTime!.format(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.access_time),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Any specific issues or complaints? (e.g., "Brakes are making noise")',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(8),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _bookAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColorOwner,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, color: Colors.white),
            SizedBox(width: 8),
            Text('Book Appointment', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
