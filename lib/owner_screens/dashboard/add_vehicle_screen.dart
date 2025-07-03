import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vehicle_verified/themes/color.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  int _currentStep = 0;

  // Controllers for all the text fields
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _engineNumberController = TextEditingController();
  final _chassisNumberController = TextEditingController();
  final _vinController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _pucProviderController = TextEditingController();

  DateTime? _registeredDate;
  DateTime? _insuranceExpiryDate;
  DateTime? _pucExpiryDate;

  // To store selected file names (simulation)
  String? _insurancePaperName;
  String? _pucPaperName;

  @override
  void dispose() {
    // Dispose all controllers
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
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        onDateSelected(picked);
      });
    }
  }

  void _selectFile(Function(String) onFileSelected) {
    // This is a simulation. In a real app, you would use a package
    // like 'file_picker' to let the user select a file.
    setState(() {
      onFileSelected('document.pdf');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Vehicle', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.primaryColorOwner,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep += 1);
          } else {
            // Last step, save the vehicle
            // TODO: Implement save logic
            print('Saving vehicle...');
            Navigator.of(context).pop();
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
                  child: Text(_currentStep == 3 ? 'SAVE' : 'NEXT', style: const TextStyle(color: Colors.white)),
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
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Vehicle Details'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Column(children: [
          _buildTextField(controller: _makeController, label: 'Vehicle Make (e.g., Honda)'),
          _buildTextField(controller: _modelController, label: 'Vehicle Model (e.g., Activa)'),
          _buildTextField(controller: _regNumberController, label: 'License Plate Number'),
        ]),
      ),
      Step(
        title: const Text('Registration Certificate (RC)'),
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
          _buildTextField(controller: _policyNumberController, label: 'Policy Number'),
          _buildTextField(controller: _insuranceProviderController, label: 'Insurance Provider'),
          _buildDateField(
            label: 'Insurance Expiry Date',
            date: _insuranceExpiryDate,
            onTap: () => _selectDate(context, (date) => _insuranceExpiryDate = date),
          ),
          _buildFileField(
            label: 'Insurance Paper',
            fileName: _insurancePaperName,
            onTap: () => _selectFile((name) => _insurancePaperName = name),
          ),
        ]),
      ),
      Step(
        title: const Text('Pollution Under Control (PUC)'),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
        content: Column(children: [
          _buildTextField(controller: _pucProviderController, label: 'PUC Provider'),
          // You can add more fields like 'Emission Levels' if needed
          _buildDateField(
            label: 'PUC Expiry Date',
            date: _pucExpiryDate,
            onTap: () => _selectDate(context, (date) => _pucExpiryDate = date),
          ),
          _buildFileField(
            label: 'Pollution Paper',
            fileName: _pucPaperName,
            onTap: () => _selectFile((name) => _pucPaperName = name),
          ),
        ]),
      ),
    ];
  }

  Widget _buildTextField({required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
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
            date != null ? DateFormat('dd MMM, yyyy').format(date) : 'Select Date',
            style: TextStyle(color: date != null ? Colors.black : Colors.grey.shade700),
          ),
        ),
      ),
    );
  }

  Widget _buildFileField({required String label, String? fileName, required VoidCallback onTap}) {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fileName ?? 'Select File',
                style: TextStyle(color: fileName != null ? Colors.black : Colors.grey.shade700),
              ),
              const Icon(Icons.attach_file, color: AppColors.primaryColorOwner),
            ],
          ),
        ),
      ),
    );
  }
}
