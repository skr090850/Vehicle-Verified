import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vehicle_verified/themes/color.dart';

class ForgotPassword extends StatefulWidget {
  final String userRole; // 'owner' or 'police'

  const ForgotPassword({super.key, required this.userRole});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Step 1: Check if any sign-in methods are associated with the email.
        List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
          _emailController.text.trim(),
        );

        // Step 2: If the list is empty, the email is not registered.
        if (signInMethods.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No user found for that email.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Step 3: If the email exists, send the password reset link.
          await FirebaseAuth.instance.sendPasswordResetEmail(
            email: _emailController.text.trim(),
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset link sent! Please check your email.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        }
      } on FirebaseAuthException catch (e) {
        // Handle other potential errors, though most are covered by the check above.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? 'An error occurred. Please try again.'),
              backgroundColor: Colors.red,
            ),
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
        title: const Text('Reset Password', style: TextStyle(color: Colors.white)),
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
        const Text(
          'Enter your registered email address to receive a password reset link.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black54),
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
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
            icon: const Icon(Icons.send_outlined, color: Colors.white),
            label: const Text('Send Reset Link', style: TextStyle(color: Colors.white)),
            onPressed: _sendResetLink,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
