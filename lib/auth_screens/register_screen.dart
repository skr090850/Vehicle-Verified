import 'package:flutter/material.dart';
import 'package:vehicle_verified/auth_screens/login_screen.dart';
import 'package:vehicle_verified/themes/color.dart';

class RegisterScreen extends StatefulWidget {
  final String userRole; // 'owner' or 'police'

  const RegisterScreen({super.key, required this.userRole});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _officialIdController = TextEditingController(); // Only for police
  final _aadharController = TextEditingController(); // For owner

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _officialIdController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  void _performRegistration() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement real Firebase Registration Logic
      // This should create a user in Firebase Auth and a document in Firestore.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen(userRole: widget.userRole)),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.userRole == 'owner';
    final primaryColor = isOwner ? AppColors.primaryColorOwner : Colors.red.shade700;
    final title = isOwner ? 'Create Owner Account' : 'Official Registration';
    final imageAsset = isOwner ? 'assets/image/owner_register_logo.png' : 'assets/image/traffic_register_logo.png';

    return Scaffold(
      backgroundColor: AppColors.backgroundColorFirst,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Added the header image back
              _buildHeader(imageAsset),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildRegistrationForm(primaryColor, isOwner),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to display the header image
  Widget _buildHeader(String imageAsset) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Image.asset(imageAsset, height: 180, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildRegistrationForm(Color primaryColor, bool isOwner) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextFormField(controller: _nameController, label: 'Full Name', icon: Icons.person_outline),
          const SizedBox(height: 20),
          _buildTextFormField(controller: _emailController, label: 'Email Address', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 20),
          _buildTextFormField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 20),
          if (isOwner) ...[
            _buildTextFormField(controller: _aadharController, label: 'Aadhar Number', icon: Icons.badge_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
          ],
          if (!isOwner) ...[
            _buildTextFormField(controller: _officialIdController, label: 'Official ID / Badge Number', icon: Icons.badge_outlined),
            const SizedBox(height: 20),
          ],
          _buildTextFormField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, obscureText: true),
          const SizedBox(height: 20),
          _buildTextFormField(controller: _confirmPasswordController, label: 'Confirm Password', icon: Icons.lock_outline, obscureText: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _performRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('Register', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account?"),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Login Now', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
