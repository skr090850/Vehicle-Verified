import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehicle_verified/themes/color.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedLanguage = 'English'; // Default language
  bool _isLoading = true;

  final List<String> _languages = ['English', 'हिन्दी (Hindi)', 'मराठी (Marathi)'];

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  /// Loads the saved language preference from Firestore.
  Future<void> _loadLanguagePreference() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()!.containsKey('language')) {
        if (mounted) {
          setState(() {
            _selectedLanguage = doc.data()!['language'];
          });
        }
      }
    } catch (e) {
      print("Error loading language preference: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Saves the selected language preference to Firestore.
  Future<void> _saveLanguagePreference() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({'language': _selectedLanguage}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Language preference saved!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save preference: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColorOwner,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.backgroundColorOwner,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: _languages.map((language) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 12),
            child: RadioListTile<String>(
              title: Text(language,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedLanguage = val);
                }
              },
              activeColor: AppColors.primaryColorOwner,
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveLanguagePreference,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColorOwner,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Save Preference',
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}
