import 'package:flutter/material.dart';
import 'package:vehicle_verified/auth_screens/login_screen.dart';
import 'package:vehicle_verified/themes/color.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthSelectorScreen extends StatefulWidget {
  const AuthSelectorScreen({super.key});

  @override
  State<AuthSelectorScreen> createState() => _AuthSelectorScreenState();
}

class _AuthSelectorScreenState extends State<AuthSelectorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundColorFirst,
              AppColors.backgroundColorOwner.withOpacity(0.5),
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final double imageSize = screenHeight * 0.22;
            final double iconSize = screenHeight * 0.08;
            final double titleFontSize = screenHeight * 0.035;
            final double subtitleFontSize = screenHeight * 0.017;
            final double brandNameFontSize = screenHeight * 0.022;
            final double verticalGap = screenHeight * 0.03;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Spacer(flex: 2),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'VEHICLE VERIFIED',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: brandNameFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildHeader(
                          imageSize: imageSize,
                          iconSize: iconSize,
                          titleFontSize: titleFontSize,
                          subtitleFontSize: subtitleFontSize,
                          verticalGap: verticalGap,
                        ),
                      ),
                    ),
                    SizedBox(height: verticalGap * 1.5),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildRoleButton(
                          context: context,
                          icon: Icons.directions_car,
                          title: 'Vehicle Owner',
                          subtitle: 'Manage your vehicle documents.',
                          color: AppColors.primaryColorOwner,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(userRole: 'owner'),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildRoleButton(
                          context: context,
                          icon: Icons.local_police,
                          title: 'Traffic Official',
                          subtitle: 'Scan & verify documents.',
                          color: Colors.red.shade700,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(userRole: 'police'),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader({
    required double imageSize,
    required double iconSize,
    required double titleFontSize,
    required double subtitleFontSize,
    required double verticalGap,
  }) {
    return Column(
      children: [
        Image.asset('assets/image/suv.png', height: imageSize),
        SizedBox(height: verticalGap * 0.8),
        Text(
          "No files, no fines, just peace of mind\nWith VehicleVerified, everything’s aligned",
          textAlign: TextAlign.center,
          style: GoogleFonts.robotoSlab(
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w500,
            // fontStyle: FontStyle.italic,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: verticalGap),
        Icon(
          Icons.verified_user,
          size: iconSize,
          color: Colors.green.shade700,
        ),
        SizedBox(height: verticalGap * 0.6),
        Text(
          'Welcome!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: verticalGap * 0.4),
        Text(
          'Please select your role to continue.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleFontSize,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        elevation: 8,
        shadowColor: color.withOpacity(0.4),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
