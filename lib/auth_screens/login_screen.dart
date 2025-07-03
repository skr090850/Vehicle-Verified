import 'package:flutter/material.dart';
import 'package:vehicle_verified/owner_screens/owner_bottom_navigation_bar.dart';
import 'package:vehicle_verified/police_screens/police_bottom_nav_screen.dart';
import 'package:vehicle_verified/auth_screens/register_screen.dart';
import 'package:vehicle_verified/auth_screens/forgot_password.dart';
import 'package:vehicle_verified/themes/color.dart';

class LoginScreen extends StatefulWidget {
  final String userRole; // 'owner' or 'police'

  const LoginScreen({super.key, required this.userRole});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _performLogin() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement real Firebase Login Logic
      final targetScreen = widget.userRole == 'owner'
          ? const OwnerBottomNavScreen()
          : const PoliceBottomNavScreen();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => targetScreen),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.userRole == 'owner';
    final primaryColor = isOwner ? AppColors.primaryColorOwner : Colors.red.shade700;
    final title = isOwner ? 'Vehicle Owner Login' : 'Official Login';
    final imageAsset = isOwner ? 'assets/image/owner_login_logo.png' : 'assets/image/traffic_login_logo.png';

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
              _buildHeader(imageAsset),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildLoginForm(primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String imageAsset) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Image.asset(imageAsset, height: 200, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildLoginForm(Color primaryColor) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email ID',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPassword(userRole: widget.userRole)),
                );
              },
              child: Text('Forgot Password?', style: TextStyle(color: primaryColor)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _performLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen(userRole: widget.userRole)),
                  );
                },
                child: Text('Register Now', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
