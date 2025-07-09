import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehicle_verified/themes/color.dart';

class AddEditDocumentScreen extends StatefulWidget {
  final String documentType;
  final String vehicleId;
  final String? documentId;

  const AddEditDocumentScreen({
    super.key,
    required this.documentType,
    required this.vehicleId,
    this.documentId,
  });

  @override
  _AddEditDocumentScreenState createState() => _AddEditDocumentScreenState();
}

class _AddEditDocumentScreenState extends State<AddEditDocumentScreen> {
  DateTime? _expiryDate;
  File? _selectedImageFile;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

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

  Future<void> _uploadAndSaveDocument() async {
    if (_selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a document image to upload.')),
      );
      return;
    }
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an expiry date.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'documents/${user.uid}/${widget.vehicleId}/$fileName';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);

      await storageRef.putFile(_selectedImageFile!);
      final String downloadUrl = await storageRef.getDownloadURL();

      final documentData = {
        'documentType': widget.documentType,
        'documentURL': downloadUrl,
        'expiryDate': Timestamp.fromDate(_expiryDate!),
        'uploadedAt': Timestamp.now(),
      };

      if (widget.documentId != null) {
        await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(widget.vehicleId)
            .collection('documents')
            .doc(widget.documentId)
            .update(documentData);
      } else {
        await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(widget.vehicleId)
            .collection('documents')
            .add(documentData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document saved successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save document: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.documentType}', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColorOwner,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showImageSourceDialog(context),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                ),
                child: _selectedImageFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImageFile!, fit: BoxFit.cover),
                )
                    : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Tap to select document'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade400)),
              leading: const Icon(Icons.calendar_today),
              title: const Text('Expiry Date'),
              subtitle: Text(
                _expiryDate == null
                    ? 'Select a date'
                    : DateFormat('dd MMM, yyyy').format(_expiryDate!),
              ),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _selectDate(context),
            ),
            const Spacer(),

            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Save Document', style: TextStyle(color: Colors.white)),
              onPressed: _uploadAndSaveDocument,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColorOwner,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}