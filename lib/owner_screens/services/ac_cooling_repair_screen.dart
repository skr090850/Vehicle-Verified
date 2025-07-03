import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vehicle_verified/themes/color.dart';

class AcCoolingRepairScreen extends StatefulWidget {
  const AcCoolingRepairScreen({super.key});

  @override
  State<AcCoolingRepairScreen> createState() => _AcCoolingRepairScreenState();
}

class _AcCoolingRepairScreenState extends State<AcCoolingRepairScreen> {
  final List<String> _vehicles = [
    'Honda Activa - DL01AB1234',
    'Maruti Swift - BR01CD5678'
  ];
  String? _selectedVehicle;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _notesController = TextEditingController();

  final List<String> _includedServices = [
    'AC Gas Level Check & Refill',
    'Compressor Check & Repair',
    'Condenser & Cooling Coil Cleaning',
    'Leak Test & Repair',
    'AC Filter Cleaning/Replacement'
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
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColorOwner,
      appBar: AppBar(
        title: const Text('AC & Cooling Repair', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.cyan.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSection(title: 'Service Includes', content: _buildInclusionsList()),
            const SizedBox(height: 24),
            _buildSection(title: 'Schedule Appointment', content: _buildSchedulingForm()),
            const SizedBox(height: 24),
            _buildSection(title: 'Describe the Issue', content: _buildNotesField()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBookingButton(),
    );
  }

  Widget _buildHeader() {
    return _buildHeaderCard(
      title: 'AC & Cooling Service',
      subtitle: 'Expert solutions for all your car AC problems.',
      icon: Icons.ac_unit,
      color: Colors.cyan.shade700,
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildInclusionsList() {
    return _buildInclusionsCard(_includedServices);
  }

  Widget _buildSchedulingForm() {
    return _buildSchedulingCard(
      vehicles: _vehicles,
      selectedVehicle: _selectedVehicle,
      selectedDate: _selectedDate,
      selectedTime: _selectedTime,
      onVehicleChanged: (value) => setState(() => _selectedVehicle = value),
      onDateTap: _pickDate,
      onTimeTap: _pickTime,
    );
  }

  Widget _buildNotesField() {
    return _buildNotesCard(_notesController, 'e.g., "AC is not cooling effectively."');
  }

  Widget _buildBookingButton() {
    return _buildBookingButtonWidget(context, 'Book AC Service');
  }
}

// Reusable Widgets (Can be moved to a separate file)

Widget _buildHeaderCard({required String title, required String subtitle, required IconData icon, required Color color}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 40),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        children: services.map((service) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(service)),
            ],
          ),
        )).toList(),
      ),
    ),
  );
}

Widget _buildSchedulingCard({
  required List<String> vehicles,
  required String? selectedVehicle,
  required DateTime? selectedDate,
  required TimeOfDay? selectedTime,
  required ValueChanged<String?> onVehicleChanged,
  required VoidCallback onDateTap,
  required VoidCallback onTimeTap,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedVehicle,
            decoration: const InputDecoration(labelText: 'Select Vehicle', border: OutlineInputBorder(), prefixIcon: Icon(Icons.directions_car)),
            items: vehicles.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: onVehicleChanged,
          ),
          const SizedBox(height: 16),
          TextFormField(
            readOnly: true,
            onTap: onDateTap,
            decoration: InputDecoration(
              labelText: 'Preferred Date',
              hintText: selectedDate == null ? 'Select a date' : DateFormat('dd MMM, yyyy').format(selectedDate),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calendar_today),
            ),
          ),
          const SizedBox(height: 16),
          Builder(builder: (context) {
            return TextFormField(
              readOnly: true,
              onTap: onTimeTap,
              decoration: InputDecoration(
                labelText: 'Preferred Time',
                hintText: selectedTime == null ? 'Select a time slot' : selectedTime.format(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.access_time),
              ),
            );
          }),
        ],
      ),
    ),
  );
}

Widget _buildNotesCard(TextEditingController controller, String hint) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(8)),
      ),
    ),
  );
}

Widget _buildBookingButtonWidget(BuildContext context, String label) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ElevatedButton.icon(
      icon: const Icon(Icons.event_available, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment Booked!')));
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
// TODO Implement this library.