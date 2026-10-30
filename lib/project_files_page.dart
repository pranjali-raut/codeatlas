
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'services/storage_services.dart';

class ProjectFilesPage extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ProjectFilesPage({
    super.key,
    required this.projectId,
    this.projectName = 'Project Files',
  });

  @override
  State<ProjectFilesPage> createState() => _ProjectFilesPageState();
}

class _ProjectFilesPageState extends State<ProjectFilesPage> {
  final StorageService _storage = StorageService.instance;
   bool _busy = false;

  bool _uploading = false;
  bool _deleting = false;

  Future<String> _getRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Please log in to access project files.');
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      throw Exception('Your user profile was not found.');
    }

    final role = doc.data()?['role'];

    if (role is! String) {
      throw Exception('Your account does not have a valid role.');
    }

    return role;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _uploadFile() async {
    setState(() => _uploading = true);

    try {
      await _storage.uploadProjectFile(widget.projectId);
      _showMessage('File uploaded successfully.');
    } catch (e) {
      _showMessage('Upload failed: $e');
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  Future<void> _deleteFile(
    String documentId,
    String storagePath,
    String fileName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete file?'),
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);

    try {
      await _storage.deleteProjectFile(documentId, storagePath);
      _showMessage('File deleted successfully.');
    } catch (e) {
      _showMessage('Delete failed: $e');
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }

  IconData _fileIcon(String fileName) {
    final name = fileName.toLowerCase();

    if (name.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (name.endsWith('.png') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg')) {
      return Icons.image;
    }
    if (name.endsWith('.zip')) return Icons.folder_zip;
    if (name.endsWith('.dart') ||
        name.endsWith('.js') ||
        name.endsWith('.json')) {
      return Icons.code;
    }

    return Icons.insert_drive_file;
  }

  String _formatSize(dynamic value) {
    final bytes = value is num ? value.toInt() : 0;

    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {

    const purple = Color(0xFFBB86FC);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: Text(widget.projectName),

       



        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF30234A),
        elevation: 0,
      ),
      body: FutureBuilder<String>(
        future: _getRole(),
        builder: (context, roleSnapshot) {
          if (roleSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (roleSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load your role.\n${roleSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final role = roleSnapshot.data!;
          final canUpload = role == 'Admin' || role == 'Team Leader';
          final canDelete = canUpload;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFEEE5FF),
                        Color(0xFFF7F1FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.folder_shared_outlined,
                        size: 36,
                        color: purple,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Project resources',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF30234A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Signed in as $role',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      if (canUpload) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _uploading ? null : _uploadFile,
                            icon: _uploading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload_file),
                            label: Text(
                              _uploading ? 'Uploading...' : 'Upload file',
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: purple,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Available files',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_deleting)
                      const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _storage.watchProjectFiles(widget.projectId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
  debugPrint('FIRESTORE FILE ERROR: ${snapshot.error}');
  debugPrint('PROJECT ID: ${widget.projectId}');

  return Center(
    child: SelectableText(
      'Error: ${snapshot.error}\n'
      'Project ID: ${widget.projectId}',
    ),
  );
}

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final files = snapshot.data?.docs ?? [];

                    if (files.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64,
                              color: Colors.black26,
                            ),
                            SizedBox(height: 12),
                            Text('No files uploaded yet.'),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final document = files[index];
                        final data = document.data();
                        final fileName =
                            data['fileName'] as String? ?? 'Unnamed file';
                        final storagePath =
                            data['storagePath'] as String? ?? '';
                        
                        final fileSize = data['fileSize'];

                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                              color: Color(0xFFEAE5F2),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFF0E8FF),
                              child: Icon(
                                _fileIcon(fileName),
                                color: const Color(0xFF8055BD),
                              ),
                            ),
                            title: Text(
                              fileName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                '${_formatSize(fileSize)}' ,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              tooltip: 'File actions',
                              onSelected: (action) async {
                                if (action == 'download') {
                                  try {
                                  
                                    
                                    await StorageService.instance.downloadProjectFile(
                                    data['storagePath'] as String,
                                    fileName: data['fileName'] as String?,
                                    );

                                  } catch (e) {
                                    _showMessage('Download failed: $e');
                                  }
                                } else if (action == 'delete' &&
                                    canDelete &&
                                    storagePath.isNotEmpty) {
                                  await _deleteFile(
                                    document.id,
                                    storagePath,
                                    fileName,
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'download',
                                  child: ListTile(
                                    leading: Icon(Icons.download_outlined),
                                    title: Text('Download'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                if (canDelete)
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      title: Text('Delete'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                              ],
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.more_vert),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
