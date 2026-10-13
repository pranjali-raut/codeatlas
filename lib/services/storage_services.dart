import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> _getRole() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception('User is not logged in.');
  }

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!userDoc.exists) {
    throw Exception('User profile not found in Firestore.');
  }

  final role = userDoc.data()?['role'];

  if (role == null || role is! String) {
    throw Exception('User role is missing in Firestore.');
  }

  return role;
}


Future<void> _requireUploadRole() async {
  final role = await _getRole();

  if (role != 'Admin' && role != 'Team Leader') {
    throw Exception(
      'Only Admins and Team Leaders can upload files.',
    );
  }
}

Future<void> _requireDeleteRole() async {
  final role = await _getRole();

  if (role != 'Admin' && role != 'Team Leader') {
    throw Exception(
      'Only Admins and Team Leaders can delete files.',
    );
  }
}