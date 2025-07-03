import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add 'intl' package to pubspec.yaml

class AddEditDocumentScreen extends StatefulWidget {
  final String documentType;

  const AddEditDocumentScreen({super.key, required this.documentType});

  @override
  _AddEditDocumentScreenState createState() => _AddEditDocumentScreenState();
}

class _AddEditDocumentScreenState extends State<AddEditDocumentScreen> {
  DateTime? _expiryDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.documentType}'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Upload Button
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
              ),
              child: InkWell(
                onTap: () {
                  // TODO: Implement image picker logic (from camera or gallery)
                  print("Upload document tapped");
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Tap to upload document'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Expiry Date Picker
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade400)),
              leading: const Icon(Icons.calendar_today),
              title: const Text('Expiry Date'),
              subtitle: Text(
                _expiryDate == null
                    ? 'Select a date'
                    : DateFormat('dd/MM/yyyy').format(_expiryDate!), // CHANGED: Date format updated
              ),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _selectDate(context),
            ),
            const Spacer(),

            // Save Button
            ElevatedButton(
              onPressed: () {
                // TODO: Implement save logic to Firestore
                print("Saving document...");
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Document'),
            ),
          ],
        ),
      ),
    );
  }
}
