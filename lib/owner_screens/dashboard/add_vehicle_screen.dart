import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehicle_verified/themes/color.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _engineNumberController = TextEditingController();
  final _chassisNumberController = TextEditingController();
  final _vinController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _pucProviderController = TextEditingController();

  String? _selectedVehicleType;
  final List<String> _vehicleTypes = [
    'Scooty',
    'Motorcycle',
    'Car (Sedan)',
    'Car (SUV)',
    'Car (Hatchback)',
    'Jeep',
    'Truck',
    'Bus',
    'Tempo',
    'Auto-rickshaw',
    'Tractor',
    'E-Rickshaw'
  ];

  DateTime? _registeredDate;
  DateTime? _insuranceExpiryDate;
  DateTime? _pucExpiryDate;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _regNumberController.dispose();
    _engineNumberController.dispose();
    _chassisNumberController.dispose();
    _vinController.dispose();
    _policyNumberController.dispose();
    _insuranceProviderController.dispose();
    _pucProviderController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        onDateSelected(picked);
      });
    }
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields in all steps.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in.");
      }

      String imagePath = 'assets/image/car_sedan.png';
      switch (_selectedVehicleType) {
        case 'Scooty':
          imagePath = 'assets/image/scooter.png';
          break;
        case 'Motorcycle':
          imagePath = 'assets/image/bike.png';
          break;
        case 'Tempo':
          imagePath = 'assets/image/tempo.png';
          break;
        case 'E-Rickshaw':
          imagePath = 'assets/image/e-Rickshaw.png';
          break;
        case 'Car (Sedan)':
          imagePath = 'assets/image/car_sedan.png';
          break;
        case 'Car (SUV)':
          imagePath = 'assets/image/car_suv.png';
          break;
        case 'Car (Hatchback)':
          imagePath = 'assets/image/car_hatchback.png';
          break;
        case 'Jeep':
          imagePath = 'assets/image/car_jeep.png';
          break;
      // Add more cases for other vehicle types if you have specific images
        case 'Truck':
          imagePath = 'assets/image/truck.png';
          break;
        case 'Bus':
          imagePath = 'assets/image/bus.png';
          break;
      }

      DocumentReference vehicleRef = await FirebaseFirestore.instance.collection('vehicles').add({
        'ownerID': user.uid,
        'make': _makeController.text.trim(),
        'model': _modelController.text.trim(),
        'registrationNumber': _regNumberController.text.trim().toUpperCase(),
        'engineNumber': _engineNumberController.text.trim(),
        'chassisNumber': _chassisNumberController.text.trim(),
        'vin': _vinController.text.trim(),
        'registeredDate': _registeredDate != null ? Timestamp.fromDate(_registeredDate!) : null,
        'vehicleType': _selectedVehicleType,
        'image': imagePath,
        'createdAt': Timestamp.now(),
        'status': 'Documents Pending',
        'health': 'Unknown',
      });

      if (_policyNumberController.text.isNotEmpty) {
        await vehicleRef.collection('documents').add({
          'documentType': 'Insurance Policy',
          'policyNumber': _policyNumberController.text.trim(),
          'provider': _insuranceProviderController.text.trim(),
          'expiryDate': _insuranceExpiryDate != null ? Timestamp.fromDate(_insuranceExpiryDate!) : null,
          'uploadedAt': Timestamp.now(),
        });
      }

      if (_pucProviderController.text.isNotEmpty) {
        await vehicleRef.collection('documents').add({
          'documentType': 'Pollution Under Control (PUC)',
          'provider': _pucProviderController.text.trim(),
          'expiryDate': _pucExpiryDate != null ? Timestamp.fromDate(_pucExpiryDate!) : null,
          'uploadedAt': Timestamp.now(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle and documents added successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add vehicle: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Vehicle', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColorOwner,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            final isLastStep = _currentStep == _buildSteps().length - 1;
            if (isLastStep) {
              _saveVehicle();
            } else {
              setState(() => _currentStep += 1);
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          onStepTapped: (step) => setState(() => _currentStep = step),
          steps: _buildSteps(),
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColorOwner),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_currentStep == _buildSteps().length - 1 ? 'SAVE VEHICLE' : 'NEXT', style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('BACK'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Vehicle Details'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Column(children: [
          DropdownButtonFormField<String>(
            value: _selectedVehicleType,
            decoration: const InputDecoration(labelText: 'Vehicle Type', border: OutlineInputBorder()),
            hint: const Text('Select vehicle type'),
            items: _vehicleTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (value) => setState(() => _selectedVehicleType = value),
            validator: (value) => value == null ? 'Please select a type' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(controller: _makeController, label: 'Vehicle Make (e.g., Honda)'),
          _buildTextField(controller: _modelController, label: 'Vehicle Model (e.g., Activa)'),
          _buildTextField(controller: _regNumberController, label: 'License Plate Number', isUpperCase: true),
        ]),
      ),
      Step(
        title: const Text('Registration Details'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Column(children: [
          _buildTextField(controller: _engineNumberController, label: 'Engine Number'),
          _buildTextField(controller: _chassisNumberController, label: 'Chassis Number'),
          _buildTextField(controller: _vinController, label: 'Vehicle Identification Number (VIN)'),
          _buildDateField(
            label: 'Registered Date',
            date: _registeredDate,
            onTap: () => _selectDate(context, (date) => _registeredDate = date),
          ),
        ]),
      ),
      Step(
        title: const Text('Insurance Information'),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        content: Column(children: [
          _buildTextField(controller: _policyNumberController, label: 'Policy Number', isOptional: true),
          _buildTextField(controller: _insuranceProviderController, label: 'Insurance Provider', isOptional: true),
          _buildDateField(
            label: 'Insurance Expiry Date',
            date: _insuranceExpiryDate,
            onTap: () => _selectDate(context, (date) => _insuranceExpiryDate = date),
          ),
        ]),
      ),
      Step(
        title: const Text('Pollution Under Control (PUC)'),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
        content: Column(children: [
          _buildTextField(controller: _pucProviderController, label: 'PUC Provider', isOptional: true),
          _buildDateField(
            label: 'PUC Expiry Date',
            date: _pucExpiryDate,
            onTap: () => _selectDate(context, (date) => _pucExpiryDate = date),
          ),
        ]),
      ),
    ];
  }

  Widget _buildTextField({required TextEditingController controller, required String label, bool isUpperCase = false, bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        textCapitalization: isUpperCase ? TextCapitalization.characters : TextCapitalization.words,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField({required String label, DateTime? date, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            date != null ? DateFormat('dd MMM, yyyy').format(date) : 'Select Date (Optional)',
            style: TextStyle(fontSize: 16, color: date != null ? Colors.black : Colors.grey.shade700),
          ),
        ),
      ),
    );
  }
}
