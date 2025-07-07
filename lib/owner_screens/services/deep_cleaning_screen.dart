import 'package:flutter/material.dart';
import 'package:vehicle_verified/themes/color.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeepCleaningScreen extends StatefulWidget {
  const DeepCleaningScreen({super.key});

  @override
  State<DeepCleaningScreen> createState() => _DeepCleaningScreenState();
}

class _DeepCleaningScreenState extends State<DeepCleaningScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<List<Map<String, dynamic>>> _vehiclesFuture;
  String? _selectedVehicleId;
  Map<String, dynamic>? _selectedVehicleData;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _notesController = TextEditingController();
  bool _isLoading = false;
  double _totalCost = 0.0;

  final List<String> _includedServices = [
    'Complete Interior Vacuuming',
    'Dashboard & Console Polishing',
    'Seat & Upholstery Shampooing',
    'Exterior Foam Wash & Wax',
    'Tire & Alloy Cleaning'
  ];

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
      final data = doc.data();
      final displayString =
          '${data['make'] ?? ''} ${data['model'] ?? ''} - ${data['registrationNumber'] ?? 'N/A'}';
      String category =
      ['Scooty', 'Motorcycle'].contains(data['vehicleType'])
          ? '2-Wheeler'
          : '4-Wheeler';
      return {'id': doc.id, 'display': displayString, 'category': category};
    }).toList();
  }

  void _calculateCost() {
    if (_selectedVehicleData == null) {
      setState(() => _totalCost = 0.0);
      return;
    }
    final category = _selectedVehicleData!['category'];
    setState(() {
      _totalCost = (category == '2-Wheeler') ? 499.0 : 1299.0;
    });
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null && mounted) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null && mounted) setState(() => _selectedTime = time);
  }

  Future<void> _bookAppointment() async {
    if (_selectedVehicleId == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select vehicle, date, and time.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await _firestore
          .collection('vehicles')
          .doc(_selectedVehicleId)
          .collection('serviceHistory')
          .add({
        'serviceType': 'Deep Cleaning',
        'servicesPerformed': _includedServices,
        'serviceDate': Timestamp.fromDate(appointmentDateTime),
        'notes': _notesController.text.trim(),
        'status': 'Booked',
        'cost': _totalCost,
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.backgroundColorOwner,
          appBar: AppBar(
            title: const Text('Deep Cleaning Service',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.purple.shade700,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: _vehiclesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Center(child: Text('No vehicles found.'));
              }
              final vehicles = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(
                      title: 'Vehicle Deep Cleaning',
                      subtitle: 'A complete spa for your beloved vehicle.',
                      icon: Icons.cleaning_services,
                      color: Colors.purple.shade700,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                        title: 'Our Cleaning Process',
                        content: _buildInclusionsCard(_includedServices)),
                    const SizedBox(height: 24),
                    _buildSection(
                        title: 'Schedule Your Service',
                        content: _buildSchedulingForm(vehicles)),
                    const SizedBox(height: 24),
                    if (_totalCost > 0)
                      _buildSection(
                          title: 'Total Cost',
                          content: _buildCostDisplayCard()),
                    const SizedBox(height: 24),
                    _buildSection(
                        title: 'Additional Notes',
                        content: _buildNotesField(
                            'e.g., "Focus on cleaning the seats"')),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar: _buildBottomButton(
            label: 'Book Cleaning Slot',
            onPressed: _isLoading ? null : _bookAppointment,
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  SizedBox(height: 20),
                  Text(
                    'Booking Appointment...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        content,
      ],
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
                  prefixIcon: Icon(Icons.directions_car)),
              items: vehicles.map((v) {
                return DropdownMenuItem<String>(
                  value: v['id'] as String,
                  child: Text(v['display'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVehicleId = value;
                  _selectedVehicleData =
                      vehicles.firstWhere((v) => v['id'] == value);
                  _calculateCost();
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

  Widget _buildNotesField(String hint) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(8)),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
      {required String title,
        required String subtitle,
        required IconData icon,
        required Color color}) {
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
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInclusionsCard(List<String> services) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: services
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
            const Text('Total Amount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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

  Widget _buildBottomButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.event_available, color: Colors.white),
        label: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColorOwner,
          minimumSize: const Size(double.infinity, 50),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
