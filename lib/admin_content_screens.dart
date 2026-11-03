import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 1) Create Project Screen
class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({Key? key}) : super(key: key);

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _repositoryController = TextEditingController();

  String? _selectedTeamLeaderId;
  String? _selectedDeveloperId;
  final Set<String> _selectedDeveloperIds = <String>{};
  bool _saving = false;

  CollectionReference<Map<String, dynamic>> get _users =>
      FirebaseFirestore.instance.collection('users');

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _repositoryController.dispose();
    super.dispose();
  }

  String _normaliseRole(dynamic value) =>
      value.toString().trim().toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ');

  bool _isTeamLeader(Map<String, dynamic> data) {
    final role = _normaliseRole(data['role']);
    return role == 'team leader' || role == 'teamleader';
  }

  bool _isDeveloper(Map<String, dynamic> data) =>
      _normaliseRole(data['role']) == 'developer';

  String _displayUser(Map<String, dynamic> data) {
    final name = (data['name'] ?? 'Unnamed user').toString().trim();
    final email = (data['email'] ?? '').toString().trim();
    return email.isEmpty ? name : '$name ($email)';
  }

  Future<void> _createProject() async {
    final name = _nameController.text.trim();
    final description = _descController.text.trim();
    final repositoryUrl = _repositoryController.text.trim();

    if (name.isEmpty) {
      _showMessage('Enter a project name.');
      return;
    }
    if (description.isEmpty) {
      _showMessage('Enter a project description.');
      return;
    }
    if (repositoryUrl.isEmpty) {
      _showMessage('Enter the GitHub repository link.');
      return;
    }
    final parsedUrl = Uri.tryParse(repositoryUrl);
    if (parsedUrl == null ||
        parsedUrl.scheme != 'https' ||
        parsedUrl.host != 'github.com') {
      _showMessage('Enter a valid GitHub URL starting with https://github.com/');
      return;
    }
    if (_selectedTeamLeaderId == null) {
      _showMessage('Select a Team Leader.');
      return;
    }
    if (_selectedDeveloperIds.isEmpty) {
      _showMessage('Select at least one Developer.');
      return;
    }

    setState(() => _saving = true);

    try {
      final admin = FirebaseAuth.instance.currentUser;
      if (admin == null) {
        throw Exception('Admin session not found. Please log in again.');
      }

      // Read the selected user records so IDs and display details are saved.
      final leaderSnapshot =
          await _users.doc(_selectedTeamLeaderId).get();
      if (!leaderSnapshot.exists) {
        throw Exception('The selected Team Leader no longer exists.');
      }
      final leaderData = leaderSnapshot.data()!;
      if (!_isTeamLeader(leaderData)) {
        throw Exception('The selected account is not a Team Leader.');
      }

      final developerSnapshots = await Future.wait(
        _selectedDeveloperIds.map((id) => _users.doc(id).get()),
      );

      final developerNames = <String>[];
      final developerDetails = <Map<String, String>>[];
      for (final doc in developerSnapshots) {
        if (!doc.exists) continue;
        final data = doc.data()!;
        if (!_isDeveloper(data)) continue;

        developerNames.add((data['name'] ?? 'Unnamed Developer').toString());
        developerDetails.add({
          'uid': doc.id,
          'name': (data['name'] ?? 'Unnamed Developer').toString(),
          'email': (data['email'] ?? '').toString(),
        });
      }

      if (developerDetails.isEmpty) {
        throw Exception('No valid Developer accounts were selected.');
      }

      await FirebaseFirestore.instance.collection('projects').add({
        'name': name,
        'description': description,
        'repositoryUrl': repositoryUrl,
        'deadline': '',
        'createdBy': admin.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'teamLeaderId': _selectedTeamLeaderId,
        'teamLeaderName':
            (leaderData['name'] ?? 'Unnamed Team Leader').toString(),
        'teamLeaderEmail': (leaderData['email'] ?? '').toString(),
        'developerIds': developerDetails.map((item) => item['uid']).toList(),
        'developerNames': developerNames,
        'developerDetails': developerDetails,
      });

      if (!mounted) return;
      _nameController.clear();
      _descController.clear();
      _repositoryController.clear();

      setState(() {
        _selectedTeamLeaderId = null;
        _selectedDeveloperId = null;
        _selectedDeveloperIds.clear();
      });

      _showMessage('Project created and selected Developers assigned successfully.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not create project: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _fieldDecoration(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: const Color(0xFFbbd0ff).withOpacity(0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Initialize Project Metadata',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter the project details, choose one Team Leader, and select one or more Developers from the dropdown lists.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _nameController,
                decoration: _fieldDecoration(
                  'Project Name',
                  hint: 'e.g. CodeAtlas',
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: _fieldDecoration(
                  'Project Description',
                  hint: 'Describe project modules, technologies, and expectations...',
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _repositoryController,
                keyboardType: TextInputType.url,
                decoration: _fieldDecoration(
                  'GitHub Repository Link',
                  hint: 'https://github.com/organization/repository',
                  icon: Icons.link,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Assign Team Leader',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _users.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Could not load Team Leaders: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final leaders = snapshot.data!.docs
                      .where((doc) => _isTeamLeader(doc.data()))
                      .toList();

                  if (leaders.isEmpty) {
                    return const Text('No Team Leader accounts found.');
                  }

                  final leaderIds = leaders.map((doc) => doc.id).toSet();
                  return DropdownButtonFormField<String>(
                    value: leaderIds.contains(_selectedTeamLeaderId)
                        ? _selectedTeamLeaderId
                        : null,
                    isExpanded: true,
                    decoration: _fieldDecoration('Select Team Leader'),
                    hint: const Text('Choose Team Leader'),
                    items: leaders.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(
                          _displayUser(doc.data()),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _selectedTeamLeaderId = value),
                  );
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Assign Developers',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _users.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Could not load Developers: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final developers = snapshot.data!.docs
                      .where((doc) => _isDeveloper(doc.data()))
                      .toList();

                  if (developers.isEmpty) {
                    return const Text('No Developer accounts found.');
                  }

                  final availableIds = developers.map((doc) => doc.id).toSet();
                  final selectedIds = _selectedDeveloperIds
                      .where(availableIds.contains)
                      .toSet();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: developers.any((doc) => doc.id == _selectedDeveloperId)
                            ? _selectedDeveloperId
                            : null,
                        isExpanded: true,
                        decoration: _fieldDecoration('Select Developer'),
                        hint: const Text('Choose a Developer to add'),
                        items: developers.map((doc) {
                          final alreadySelected = selectedIds.contains(doc.id);
                          return DropdownMenuItem<String>(
                            value: doc.id,
                            enabled: !alreadySelected,
                            child: Text(
                              '${_displayUser(doc.data())}${alreadySelected ? ' (Selected)' : ''}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: _saving
                            ? null
                            : (value) {
                                if (value == null) return;
                                setState(() {
                                  _selectedDeveloperIds.add(value);
                                  _selectedDeveloperId = null;
                                });
                              },
                      ),
                      const SizedBox(height: 12),
                      if (selectedIds.isEmpty)
                        const Text(
                          'No Developers selected yet.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: developers
                              .where((doc) => selectedIds.contains(doc.id))
                              .map((doc) {
                            final data = doc.data();
                            return InputChip(
                              avatar: const CircleAvatar(
                                backgroundColor: Color(0xFFE7C6FF),
                                child: Icon(Icons.person_outline, size: 17),
                              ),
                              label: Text(_displayUser(data)),
                              onDeleted: _saving
                                  ? null
                                  : () => setState(
                                        () => _selectedDeveloperIds.remove(doc.id),
                                      ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        '${selectedIds.length} Developer(s) selected',
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _createProject,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(_saving ? 'Creating Project...' : 'Create Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7653B6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2) Existing Admin screens continue below.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text("Developer Onboarding Progress Metrics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetricCard("Active Onboardees", "12", Icons.group, const Color(0xFFffd6ff))),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard("Avg Completion Time", "4.5 Days", Icons.timer, const Color(0xFFe7c6ff))),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard("RAG Queries Solved", "342", Icons.psychology, const Color(0xFFbbd0ff))),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }
}

// 2b) Teams Screen

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('projects')
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading teams: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final projects = snapshot.data?.docs ?? [];

        if (projects.isEmpty) {
          return const Center(
            child: Text(
              'No projects available.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: projects.length,

          itemBuilder: (context, index) {
            final projectData = projects[index].data();

            final projectName =
                (projectData['name'] ?? 'Unnamed Project').toString();

            final teamLeaderId =
                (projectData['teamLeaderId'] ?? '').toString();

            // Supports both a single developer UID and a list of UIDs.
            final developerData = projectData['developerIds'];

            final List<String> developerIds =
                developerData is List
                    ? developerData.map((e) => e.toString()).toList()
                    : developerData is String &&
                            developerData.isNotEmpty
                        ? [developerData]
                        : [];

            return FutureBuilder<List<String>>(
              future: () async {
                final List<String> memberNames = [];

                // Fetch Team Leader name
                if (teamLeaderId.isNotEmpty) {
                  final leaderDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(teamLeaderId)
                      .get();

                  if (leaderDoc.exists) {
                    final leaderName =
                        leaderDoc.data()?['name']?.toString() ??
                            'Name not available';

                    memberNames.add(leaderName);
                  } else {
                    memberNames.add('Team Leader not found');
                  }
                } else {
                  memberNames.add('Not assigned');
                }

                // Fetch Developer names
                for (final developerId in developerIds) {
                  final developerDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(developerId)
                      .get();

                  if (developerDoc.exists) {
                    final developerName =
                        developerDoc.data()?['name']?.toString() ??
                            'Name not available';

                    memberNames.add(developerName);
                  } else {
                    memberNames.add('Developer not found');
                  }
                }

                return memberNames;
              }(),

              builder: (context, memberSnapshot) {
                final memberNames = memberSnapshot.data ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Project Name
                        Row(
                          children: [
                            const Icon(
                              Icons.folder_rounded,
                              color: Color(0xFF7653B6),
                              size: 25,
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                projectName,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        const Divider(),

                        // Team Details Heading
                        const Text(
                          'Project Team',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 14),

                        if (memberSnapshot.connectionState ==
                            ConnectionState.waiting)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (memberSnapshot.hasError)
                          const Text('Unable to load team members.')
                        else ...[
                          // Team Leader
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Color(0xFFE7C6FF),
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xFF7653B6),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Team Leader',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),

                                    Text(
                                      memberNames.isNotEmpty
                                          ? memberNames[0]
                                          : 'Not assigned',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons.verified_user_outlined,
                                color: Color(0xFF7653B6),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Developers Heading
                          const Text(
                            'Developers',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 10),

                          if (developerIds.isEmpty)
                            const Text(
                              'No developers assigned.',
                              style: TextStyle(color: Colors.grey),
                            )
                          else
                            ...List.generate(
                              developerIds.length,
                              (developerIndex) {
                                final nameIndex = developerIndex + 1;

                                final developerName =
                                    memberNames.length > nameIndex
                                        ? memberNames[nameIndex]
                                        : 'Loading...';

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 12,
                                  ),

                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 19,
                                        backgroundColor:
                                            Color(0xFFBBd0FF),
                                        child: Icon(
                                          Icons.person_outline,
                                          color: Color(0xFF7653B6),
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: Text(
                                          developerName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                      const Text(
                                        'Developer',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ],
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


// 2c) Schedule Screen
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Day-wise Onboarding Schedule View", style: TextStyle(fontSize: 16)),
    );
  }
}


