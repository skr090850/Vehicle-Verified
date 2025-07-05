import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vehicle_verified/auth_screens/auth_selector_screen.dart';
import 'package:vehicle_verified/owner_screens/owner_bottom_navigation_bar.dart';
import 'package:vehicle_verified/police_screens/police_bottom_nav_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Agar user login hai, to RoleBasedRedirect dikhayein
        if (snapshot.hasData) {
          return RoleBasedRedirect(userId: snapshot.data!.uid);
        }
        else {
          return const AuthSelectorScreen();
        }
      },
    );
  }
}

class RoleBasedRedirect extends StatefulWidget {
  final String userId;
  const RoleBasedRedirect({super.key, required this.userId});

  @override
  State<RoleBasedRedirect> createState() => _RoleBasedRedirectState();
}

class _RoleBasedRedirectState extends State<RoleBasedRedirect> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final userRole = snapshot.data!.data()!['role'];

          if (userRole == 'police') {
            return const PoliceBottomNavScreen();
          } else {
            return const OwnerBottomNavScreen();
          }
        }

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("User data not found. Logging out."),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text("Logout"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
