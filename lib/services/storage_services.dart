
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String bucket = 'codeatlas-files';
  static const int maxFileSizeBytes = 20 * 1024 * 1024;

  Future<String> _getRole() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

   final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .get();


    if (!doc.exists) {
      throw Exception('User profile not found in Firestore.');
    }

    final role = doc.data()?['role'];

    if (role is! String) {
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

  String _contentType(String fileName) {
    final name = fileName.toLowerCase();

    if (name.endsWith('.pdf')) return 'application/pdf';
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (name.endsWith('.txt')) return 'text/plain';
    if (name.endsWith('.json')) return 'application/json';
    if (name.endsWith('.zip')) return 'application/zip';
    if (name.endsWith('.dart')) return 'text/plain';
    if (name.endsWith('.md')) return 'text/markdown';

    return 'application/octet-stream';
  }

  Future<void> uploadProjectFile(String projectId) async {
    await _requireUploadRole();

    final user = _auth.currentUser!;

final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .get();

    final userName = doc.data()?['name'] as String? ?? 'Unknown user';
   
final PlatformFile? file = await FilePicker.pickFile();

if (file == null) {
  return; // User cancelled selection.
}

final Uint8List bytes = await file.readAsBytes();

if (bytes.length > maxFileSizeBytes) {
  throw Exception('Maximum allowed file size is 20 MB.');
}


    final safeName = file.name.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );

    final storagePath =
        'projects/$projectId/${user.uid}/'
        '${DateTime.now().millisecondsSinceEpoch}_$safeName';

    await _supabase.storage.from(bucket).uploadBinary(
      storagePath,
      bytes,
      fileOptions: FileOptions(
        contentType: _contentType(file.name),
        upsert: false,
      ),
    );

    try {
      await _firestore.collection('project_files').add({
        'projectId': projectId,
        'fileName': file.name,
        'storagePath': storagePath,
        'uploadedBy': userName,
        'fileType': _contentType(file.name),
        'fileSize': bytes.length,
        'uploadedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Clean up the object if writing metadata fails.
      try {
        await _supabase.storage.from(bucket).remove([storagePath]);
      } catch (_) {
        // Keep the original Firestore error.
      }
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchProjectFiles(
    String projectId,
  ) {
    return _firestore
        .collection('project_files')
        .where('projectId', isEqualTo: projectId)
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  Future<void> downloadProjectFile(String storagePath) async {
    // Supabase RLS must authorize access before a signed URL is issued.
    final signedUrl = await _supabase.storage
        .from(bucket)
        .createSignedUrl(storagePath, 60);

    final uri = Uri.parse(signedUrl);

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      throw Exception('Could not open the download link.');
    }
  }

  Future<void> deleteProjectFile(
    String documentId,
    String storagePath,
  ) async {
    await _requireDeleteRole();

    await _supabase.storage.from(bucket).remove([storagePath]);

    await _firestore
        .collection('project_files')
        .doc(documentId)
        .delete();
  }
}
