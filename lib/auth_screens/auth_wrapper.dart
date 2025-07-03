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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return RoleBasedRedirect(userId: snapshot.data!.uid);
        }

        return const AuthSelectorScreen();
      },
    );
  }
}

class RoleBasedRedirect extends StatelessWidget {
  final String userId;
  const RoleBasedRedirect({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const AuthSelectorScreen();
        }

        final data = userSnapshot.data!.data() as Map<String, dynamic>;
        final String role = data['role'] ?? 'owner';

        if (role == 'police') {
          return const PoliceBottomNavScreen();
        } else {
          return const OwnerBottomNavScreen();
        }
      },
    );
  }
}
