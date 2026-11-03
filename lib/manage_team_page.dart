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
  bool _initialized = false;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _teamStream;

  @override
  void initState() {
    super.initState();

    final leader = FirebaseAuth.instance.currentUser;
    if (leader != null) {
      // Cache streams so typing in the search field does not restart them.
      _usersStream = _db.collection('users').snapshots();
      _teamStream = _db.collection('teams').doc(leader.uid).snapshots();
    }
  }

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

      // Read the previous team membership before changing it.
      final previousTeamSnapshot = await teamRef.get();
      final previousRaw = previousTeamSnapshot.data()?['memberIds'];
      final previousMembers = previousRaw is List
          ? previousRaw.map((id) => id.toString()).toSet()
          : <String>{};

      final removedIds = previousMembers.difference(_selectedIds);

      // Read all projects assigned to this Team Leader.
      final projectSnapshot = await _db
          .collection('projects')
          .where('teamLeaderId', isEqualTo: leader.uid)
          .get();

      final developerMap = {
        for (final doc in developers) doc.id: doc,
      };

      // Validate every selected account before writing anything.
      for (final id in _selectedIds) {
        final developer = developerMap[id];

        if (developer == null) {
          throw Exception(
            'A selected developer account was not found. Refresh and try again.',
          );
        }

        final assignedLeader = developer.data()['teamLeaderId'];

        if (assignedLeader != null &&
            assignedLeader.toString().isNotEmpty &&
            assignedLeader != leader.uid) {
          throw Exception(
            '${developer.data()['name'] ?? 'Developer'} belongs to another team.',
          );
        }
      }

      // Build writes, then commit in batches of at most 450 operations.
      final writes = <void Function(WriteBatch)>[];

      for (final id in _selectedIds) {
        final developer = developerMap[id]!;
        writes.add((batch) {
          batch.update(developer.reference, {
            'teamLeaderId': leader.uid,
            'teamId': leader.uid,
          });
        });
      }

      // Clear team fields for developers removed from this team.
      for (final developer in developers) {
        final data = developer.data();

        if (data['teamLeaderId'] == leader.uid &&
            !_selectedIds.contains(developer.id)) {
          writes.add((batch) {
            batch.update(developer.reference, {
              'teamLeaderId': null,
              'teamId': null,
            });
          });
        }
      }

      // Persist the selected team.
      writes.add((batch) {
        batch.set(
          teamRef,
          {
            'teamLeaderId': leader.uid,
            'memberIds': _selectedIds.toList(),
            'teamName': 'Team ${leader.uid}',
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });

      // Add every selected team member to every project under this leader.
      for (final project in projectSnapshot.docs) {
        writes.add((batch) {
          batch.update(project.reference, {
            'developerIds': FieldValue.arrayUnion(_selectedIds.toList()),
          });
        });

        // Remove members removed from the team from these projects.
        if (removedIds.isNotEmpty) {
          writes.add((batch) {
            batch.update(project.reference, {
              'developerIds': FieldValue.arrayRemove(removedIds.toList()),
            });
          });
        }
      }

      for (var start = 0; start < writes.length; start += 450) {
        final batch = _db.batch();
        final end = (start + 450 < writes.length)
            ? start + 450
            : writes.length;

        for (var i = start; i < end; i++) {
          writes[i](batch);
        }

        await batch.commit();
      }

      if (!mounted) return;

      _showMessage(
        'Team saved and synchronized with all your projects.',
      );
      widget.onSaved?.call();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not save team: $e');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildDeveloperList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> developers,
    String leaderId,
  ) {
    final filtered = developers.where((doc) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().toLowerCase();
      final email = (data['email'] ?? '').toString().toLowerCase();

      return name.contains(_search) || email.contains(_search);
    }).toList();

    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(child: Text('No matching developers found.')),
      );
    }

    return Column(
      children: filtered.map((developer) {
        final data = developer.data();
        final name = (data['name'] ?? 'Unnamed Developer').toString();
        final email = (data['email'] ?? '').toString();
        final assignedLeader = data['teamLeaderId'];

        final belongsToOtherTeam = assignedLeader != null &&
            assignedLeader.toString().isNotEmpty &&
            assignedLeader != leaderId;

        final selected = _selectedIds.contains(developer.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            value: selected,
            onChanged: _saving || belongsToOtherTeam
                ? null
                : (checked) {
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
            title: Text(name),
            subtitle: Text(
              belongsToOtherTeam
                  ? '$email • Assigned to another team'
                  : email,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leader = FirebaseAuth.instance.currentUser;

    if (leader == null) {
      return const Center(child: Text('Please log in to manage your team.'));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _teamStream,
      builder: (context, teamSnapshot) {
        if (teamSnapshot.hasError) {
          return Center(child: Text('Team error: ${teamSnapshot.error}'));
        }

        if (teamSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Restore saved members from teams/{teamLeaderUid}/memberIds.
        if (!_initialized) {
          final memberIds = teamSnapshot.data?.data()?['memberIds'];
          if (memberIds is List) {
            _selectedIds.addAll(
              memberIds.map((id) => id.toString()),
            );
          }
          _initialized = true;
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _usersStream,
          builder: (context, userSnapshot) {
            if (userSnapshot.hasError) {
              return Center(
                child: Text('Could not load users: ${userSnapshot.error}'),
              );
            }

            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Load all user documents, then filter Developer role
            // without depending on capitalization.
            final developers = (userSnapshot.data?.docs ?? [])
                .where((doc) {
              final role = (doc.data()['role'] ?? '')
                  .toString()
                  .trim()
                  .toLowerCase();
              return role == 'developer';
            }).toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 600;

                final availableIds = developers.where((doc) {
                  final assigned = doc.data()['teamLeaderId'];
                  return assigned == null ||
                      assigned.toString().isEmpty ||
                      assigned == leader.uid;
                }).map((doc) => doc.id).toSet();

                final allAvailableSelected = availableIds.isNotEmpty &&
                    availableIds.every(_selectedIds.contains);

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
                            'Select your team members. Every team member will be assigned to all projects under you.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 22),

                          TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _search = value.trim().toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search developers by name or email',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _search = '');
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(Icons.groups_outlined, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${_selectedIds.length} selected / ${developers.length} developers',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _saving
                                        ? null
                                        : () {
                                            setState(() {
                                              if (allAvailableSelected) {
                                                _selectedIds.removeAll(
                                                  availableIds,
                                                );
                                              } else {
                                                _selectedIds.addAll(
                                                  availableIds,
                                                );
                                              }
                                            });
                                          },
                                    child: Text(
                                      allAvailableSelected
                                          ? 'Clear available'
                                          : 'Select available',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (developers.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(30),
                              child: Center(
                                child: Text(
                                  'No developer accounts found in the users collection.',
                                ),
                              ),
                            )
                          else
                            _buildDeveloperList(developers, leader.uid),

                          const SizedBox(height: 22),

                          SizedBox(
                            width: compact ? double.infinity : 340,
                            child: FilledButton.icon(
                              onPressed: _saving || _selectedIds.isEmpty
                                  ? null
                                  : () => _saveMembers(developers),
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
                                _saving
                                    ? 'Saving...'
                                    : 'Save Team & Assign All Projects',
                              ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
