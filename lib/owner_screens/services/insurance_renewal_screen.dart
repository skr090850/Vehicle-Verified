import 'package:flutter/material.dart';
import 'package:vehicle_verified/themes/color.dart';
import 'package:intl/intl.dart';

class InsuranceRenewalScreen extends StatefulWidget {
  const InsuranceRenewalScreen({super.key});

  @override
  State<InsuranceRenewalScreen> createState() => _InsuranceRenewalScreenState();
}

class _InsuranceRenewalScreenState extends State<InsuranceRenewalScreen> {
  final List<String> _vehicles = [
    'Honda Activa - DL01AB1234',
    'Maruti Swift - BR01CD5678'
  ];
  String? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = _vehicles.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColorOwner,
      appBar: AppBar(
        title: const Text('Insurance Renewal', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(
              title: 'Renew Your Insurance',
              subtitle: 'Get the best quotes and renew your policy instantly.',
              icon: Icons.shield,
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Select Vehicle',
              content: _buildVehicleSelectionCard(
                vehicles: _vehicles,
                selectedVehicle: _selectedVehicle,
                onVehicleChanged: (value) => setState(() => _selectedVehicle = value),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Upload Previous Policy (Optional)',
              content: _buildFilePicker(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBookingButtonWidget(context, 'Get Renewal Quotes'),
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

  Widget _buildVehicleSelectionCard({
    required List<String> vehicles,
    required String? selectedVehicle,
    required ValueChanged<String?> onVehicleChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropdownButtonFormField<String>(
          value: selectedVehicle,
          decoration: const InputDecoration(labelText: 'Select Vehicle', border: OutlineInputBorder(), prefixIcon: Icon(Icons.directions_car)),
          items: vehicles.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: onVehicleChanged,
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.attach_file),
        title: const Text('Select policy PDF/Image'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO: Implement file picker logic
        },
      ),
    );
  }
}

// --- Reusable Widgets ---

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

Widget _buildBookingButtonWidget(BuildContext context, String label) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ElevatedButton.icon(
      icon: const Icon(Icons.event_available, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Processing your request...')));
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
