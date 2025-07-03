import 'package:flutter/material.dart';
import 'package:vehicle_verified/owner_screens/dashboard/owner_dashboard_screen.dart';
import 'package:vehicle_verified/owner_screens/services/owner_service_screen.dart';
import 'package:vehicle_verified/owner_screens/profile/owner_profile_screen.dart';
import 'package:vehicle_verified/themes/color.dart';

class OwnerBottomNavScreen extends StatefulWidget {
  const OwnerBottomNavScreen({super.key});

  @override
  _OwnerBottomNavScreenState createState() => _OwnerBottomNavScreenState();
}

class _OwnerBottomNavScreenState extends State<OwnerBottomNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const OwnerDashboardScreen(),
    const OwnerServiceScreen(),
    const OwnerProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody allows the body to go behind the bottom navigation bar.
      // This is crucial for the overlay effect to work correctly with lists.
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // Use the bottomNavigationBar property for the custom floating bar.
      bottomNavigationBar: _buildOverlayBottomNavBar(),
    );
  }

  Widget _buildOverlayBottomNavBar() {
    return Container(
      // Margin to create the floating effect
      margin: const EdgeInsets.all(20.0),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        // Border radius for rounded corners
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', index: 0),
          _buildNavItem(icon: Icons.miscellaneous_services_rounded, label: 'Services', index: 1),
          _buildNavItem(icon: Icons.person_rounded, label: 'Profile', index: 2),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColorOwner.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.primaryColorOwner : Colors.grey.shade500,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryColorOwner : Colors.grey.shade500,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
            ),
          )
        ],
      ),
    );
  }
}
