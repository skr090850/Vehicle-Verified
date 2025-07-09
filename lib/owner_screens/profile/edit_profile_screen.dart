import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vehicle_verified/themes/color.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  String? _profileImageUrl;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
      }
      return;
    }

    try {
      final DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && mounted) {
        final data = userDoc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        setState(() {
          _profileImageUrl = data['profileImageUrl'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch data: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      String? newImageUrl = _profileImageUrl;
      if (_selectedImageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(user.uid)
            .child('profile.jpg');
        await storageRef.putFile(_selectedImageFile!);
        newImageUrl = await storageRef.getDownloadURL();
      }

      await _firestore.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'profileImageUrl': newImageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
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
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColorOwner,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.backgroundColorOwner,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfileImage(),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _updateUserData,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColorOwner,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primaryColorOwner.withOpacity(0.1),
          backgroundImage: _selectedImageFile != null
              ? FileImage(_selectedImageFile!)
              : (_profileImageUrl != null
              ? NetworkImage(_profileImageUrl!)
              : null) as ImageProvider?,
          child: (_selectedImageFile == null && _profileImageUrl == null)
              ? const Icon(
            Icons.person,
            size: 60,
            color: AppColors.primaryColorOwner,
          )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryColorOwner,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
              onPressed: _pickImage,
            ),
          ),
        ),
      ],
    );
  }
}
