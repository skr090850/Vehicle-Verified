import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vehicle_verified/themes/color.dart';

class GeneralMaintenanceScreen extends StatefulWidget {
  const GeneralMaintenanceScreen({super.key});

  @override
  State<GeneralMaintenanceScreen> createState() =>
      _GeneralMaintenanceScreenState();
}

class _GeneralMaintenanceScreenState extends State<GeneralMaintenanceScreen> {
  // --- MOCK DATA ---
  final List<String> _vehicles = [
    'Honda Activa - DL01AB1234',
    'Maruti Swift - BR01CD5678'
  ];
  String? _selectedVehicle;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _notesController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _selectedVehicle = _vehicles.first;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
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
      body: SingleChildScrollView(
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
              content: _buildSchedulingForm(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Additional Notes',
              content: _buildNotesField(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBookingButton(),
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
                  'Keep your vehicle in top condition with our expert service.',
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

  Widget _buildSchedulingForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedVehicle,
              decoration: const InputDecoration(
                labelText: 'Select Vehicle',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              items: _vehicles
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVehicle = value;
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
      child: ElevatedButton.icon(
        icon: const Icon(Icons.event_available, color: Colors.white),
        label: const Text('Book Appointment', style: TextStyle(color: Colors.white, fontSize: 16)),
        onPressed: () {
          // TODO: Implement booking logic
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment Booked!')),
          );
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColorOwner,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
