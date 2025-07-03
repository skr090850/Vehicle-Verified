import 'package:flutter/material.dart';
import 'package:vehicle_verified/auth_screens/changed_password.dart';
import 'package:vehicle_verified/themes/color.dart';

class ForgotPassword extends StatefulWidget {
  final String userRole; // 'owner' or 'police'

  const ForgotPassword({super.key, required this.userRole});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleButtonPress() {
    if (_formKey.currentState!.validate()) {
      if (!_isOtpSent) {
        // --- Step 1: Send OTP ---
        setState(() {
          _isLoading = true;
        });
        // TODO: Implement real Firebase OTP sending logic
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _isLoading = false;
            _isOtpSent = true;
          });
        });
      } else {
        // --- Step 2: Verify OTP ---
        setState(() {
          _isLoading = true;
        });
        // TODO: Implement real Firebase OTP verification logic
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ChangePasswordScreen(
                phoneNumber: _phoneController.text,
                userRole: widget.userRole,
              ),
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.userRole == 'owner';
    final primaryColor = isOwner ? AppColors.primaryColorOwner : Colors.red.shade700;
    final imageAsset = isOwner
        ? 'assets/image/owner_forgot_password.png' // Create this asset
        : 'assets/image/traffic_forgot_password.png'; // Create this asset

    return Scaffold(
      backgroundColor: AppColors.backgroundColorFirst,
      appBar: AppBar(
        title: const Text('Forgot Password', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildHeader(imageAsset),
            const SizedBox(height: 24),
            _buildForm(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String imageAsset) {
    return Column(
      children: [
        Image.asset(imageAsset, height: 200, fit: BoxFit.contain),
        const SizedBox(height: 24),
        Text(
          !_isOtpSent
              ? 'Enter your registered phone number to receive a verification code.'
              : 'An OTP has been sent to your phone. Please enter it below.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildForm(Color primaryColor) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phone number field (always visible)
          TextFormField(
            controller: _phoneController,
            enabled: !_isOtpSent,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_android),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.length != 10) {
                return 'Please enter a valid 10-digit phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // OTP field (visible after OTP is sent)
          if (_isOtpSent)
            TextFormField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                prefixIcon: Icon(Icons.password),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.length != 6) {
                  return 'Please enter a valid 6-digit OTP';
                }
                return null;
              },
            ),
          const SizedBox(height: 32),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
            onPressed: _handleButtonPress,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Text(
              !_isOtpSent ? 'Send OTP' : 'Verify OTP',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
