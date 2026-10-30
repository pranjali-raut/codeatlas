import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 1) Create Project Screen
class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({Key? key}) : super(key: key);

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedFileName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Initialize Project Metadata",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Provide project details and upload source documents (README, Architecture PDFs) for Supabase Storage & AI analysis.",
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 24),
              
              // Project Name Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Project Name',
                  hintText: 'e.g., CodeAtlas / InitifyApp',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: const Color(0xFFbbd0ff).withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 20),
              
              // Description Field
              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Project Description',
                  hintText: 'Describe modules, technologies, and system expectations...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: const Color(0xFFbbd0ff).withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 20),

              // File Upload Section (Supabase Storage Target)
              const Text("Project Files / Documentation", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFc8b6ff), width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFffd6ff).withOpacity(0.2),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.deepPurple),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFileName ?? "Drag & drop README, API docs, or PDFs here",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFb8c0ff),
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedFileName = "README_v2.md & architecture_spec.pdf selected";
                        });
                      },
                      child: const Text("Browse Supabase Buckets"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFc8b6ff),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Project saved to Firestore & files uploaded to Supabase!")),
                    );
                  },
                  child: const Text("Generate AI Onboarding Experience", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2a) Progress Screen
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


