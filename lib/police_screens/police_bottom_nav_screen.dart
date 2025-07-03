import 'package:flutter/material.dart';
import 'package:vehicle_verified/police_screens/police_home_screen.dart';
import 'package:vehicle_verified/police_screens/police_profile_screen.dart';

class PoliceBottomNavScreen extends StatefulWidget {
  const PoliceBottomNavScreen({super.key});

  @override
  State<PoliceBottomNavScreen> createState() => _PoliceBottomNavScreenState();
}

class _PoliceBottomNavScreenState extends State<PoliceBottomNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PoliceHomeScreen(),
    const PoliceProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows the body to go behind the nav bar
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildOverlayBottomNavBar(),
    );
  }

  Widget _buildOverlayBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(20.0),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
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
          _buildNavItem(icon: Icons.qr_code_scanner, label: 'Scanner', index: 0),
          _buildNavItem(icon: Icons.person_outline, label: 'Profile', index: 1),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final bool isSelected = _currentIndex == index;
    final Color color = isSelected ? Colors.red.shade700 : Colors.grey.shade500;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.red.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
            ),
          )
        ],
      ),
    );
  }
}
