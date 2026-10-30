
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageTeamPage extends StatefulWidget {
  final VoidCallback? onSaved;

  const ManageTeamPage({super.key, this.onSaved});

  @override
  State<ManageTeamPage> createState() => _ManageTeamPageState();
}

class _ManageTeamPageState extends State<ManageTeamPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  final Set<String> _selectedIds = {};
  String _search = '';
  bool _saving = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


Future<void> _saveMembers(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> developers,
) async {
  final leader = FirebaseAuth.instance.currentUser;

  if (leader == null) {
    _showMessage('Please log in again.');
    return;
  }

  if (_selectedIds.isEmpty) {
    _showMessage('Select at least one developer.');
    return;
  }

  setState(() => _saving = true);

  try {
    final teamRef = _db.collection('teams').doc(leader.uid);

    final batch = _db.batch();

    for (final developer in developers) {
      final data = developer.data();
      final currentLeaderId = data['teamLeaderId'] as String?;

      if (_selectedIds.contains(developer.id)) {
        if (currentLeaderId != null &&
            currentLeaderId.isNotEmpty &&
            currentLeaderId != leader.uid) {
          throw Exception(
            '${data['name'] ?? 'This developer'} belongs to another team.',
          );
        }

        batch.update(developer.reference, {
          'teamLeaderId': leader.uid,
          'teamId': leader.uid,
        });
      } else if (currentLeaderId == leader.uid) {
        batch.update(developer.reference, {
          'teamLeaderId': null,
          'teamId': null,
        });
      }
    }

    // Create or update the team document automatically.
    batch.set(
      teamRef,
      {
        'teamLeaderId': leader.uid,
        'memberIds': _selectedIds.toList(),
        'teamName': 'Team ${leader.uid}',
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();

    if (!mounted) return;

    _showMessage('Team members saved successfully.');
    widget.onSaved?.call();
  } catch (e) {
    if (!mounted) return;
    _showMessage('Could not save team members: $e');
  } finally {
    if (mounted) {
      setState(() => _saving = false);
    }
  }
}


  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leader = FirebaseAuth.instance.currentUser;

    if (leader == null) {
      return const Center(child: Text('Please log in to manage your team.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('users').where('role', isEqualTo: 'Developer').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Could not load developers: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final developers = snapshot.data?.docs ?? [];

        // Show developers who are unassigned or already belong to this leader.
        final available = developers.where((doc) {
          final data = doc.data();
          final assignedLeader = data['teamLeaderId'] as String?;
          return assignedLeader == null ||
              assignedLeader.isEmpty ||
              assignedLeader == leader.uid;
        }).toList();

        // Initialize existing members once, without resetting checkbox
        // changes every time the stream refreshes.
        if (!_initialized) {
          _selectedIds.addAll(
            available.where((doc) =>
              doc.data()['teamLeaderId'] == leader.uid
            ).map((doc) => doc.id),
          );
          _initialized = true;
        }

        final filtered = available.where((doc) {
          final data = doc.data();
          final name = (data['name'] ?? '').toString().toLowerCase();
          final email = (data['email'] ?? '').toString().toLowerCase();
          return name.contains(_search) || email.contains(_search);
        }).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 600;

            return SingleChildScrollView(
              padding: EdgeInsets.all(compact ? 14 : 26),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Manage Team',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Select developers to add to your team.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _search = value.toLowerCase().trim()),
                        decoration: InputDecoration(
                          hintText: 'Search by name or email',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _search = '');
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.groups_outlined, size: 30),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${_selectedIds.length} developer(s) selected',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    if (_selectedIds.length == available.length) {
                                      _selectedIds.clear();
                                    } else {
                                      _selectedIds
                                        ..clear()
                                        ..addAll(available.map((doc) => doc.id));
                                    }
                                  });
                                },
                                child: Text(
                                  _selectedIds.length == available.length
                                      ? 'Clear all'
                                      : 'Select all',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(28),
                          child: Center(
                            child: Text('No available developers found.'),
                          ),
                        )
                      else
                        ...filtered.map((developer) {
                          final data = developer.data();
                          final name = (data['name'] ?? 'Unnamed Developer')
                              .toString();
                          final email = (data['email'] ?? '').toString();
                          final selected = _selectedIds.contains(developer.id);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: CheckboxListTile(
                              value: selected,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedIds.add(developer.id);
                                  } else {
                                    _selectedIds.remove(developer.id);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              secondary: CircleAvatar(
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                ),
                              ),
                              title: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                email,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: compact ? double.infinity : 240,
                        child: FilledButton.icon(
                          onPressed: _saving
                              ? null
                              : () => _saveMembers(available),
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _saving ? 'Saving...' : 'Save & View Team Members',
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _initialized = false;
}
