
import 'package:codeatlas/admin_dashboard.dart';
import 'package:codeatlas/developer_dashboard.dart';
import 'package:codeatlas/team_leader_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'loginpage.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const LoginPage();
        }

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (profileSnapshot.hasError ||
                !profileSnapshot.hasData ||
                !profileSnapshot.data!.exists) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Unable to load your profile.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            FirebaseAuth.instance.signOut(),
                        child: const Text('Sign out'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final role =
                profileSnapshot.data!.data()?['role'];

            switch (role) {
              case 'Admin':
                return const AdminDashboard();

              case 'Team Leader':
                return const TeamLeaderDashboard();

              case 'Developer':
                return const DeveloperDashboard();

              default:
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Your account has an invalid role.',
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              FirebaseAuth.instance.signOut(),
                          child: const Text('Sign out'),
                        ),
                      ],
                    ),
                  ),
                );
            }
          },
        );
      },
    );
  }
}
