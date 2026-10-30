import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'developer_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chatbot_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'team_leader_dashboard.dart';
import 'team_leader_content.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperPageContent extends StatefulWidget {
  final String page;

  const DeveloperPageContent({super.key, required this.page});

  @override
  State<DeveloperPageContent> createState() => _DeveloperPageContentState();
}

class _DeveloperPageContentState extends State<DeveloperPageContent> {
  final List<Map<String, String>> tasks = [
    {
      'title': 'Create login page',
      'description': 'Build a responsive login interface.',
      'priority': 'High',
      'status': 'In Progress',
    },
    {
      'title': 'Connect authentication API',
      'description': 'Integrate the login API.',
      'priority': 'Medium',
      'status': 'Pending',
    },
    {
      'title': 'Design dashboard cards',
      'description': 'Create reusable dashboard components.',
      'priority': 'Low',
      'status': 'Completed',
    },
  ];

  final TextEditingController chatController = TextEditingController();
  bool isChatLoading = false;
  final List<String> chatMessages = [
    'Hi! I am your CodeAtlas assistant. Ask me about project tasks, Git commands, or debugging.',
  ];

  @override
  void dispose() {
    chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.page) {
      case 'Summary':
        return ProjectSummaryContent();
      case 'Files':
        return filesPage();
      case 'Assigned':
        return taskPage(completed: false);
      case 'Completed':
        return taskPage(completed: true);
      case 'Chatbot':
  return const SizedBox.shrink();
      case 'Repo':
        return gitPage(branch: false);
      case 'Branch':
        return gitPage(branch: true);
      case 'My Profile':
        return profilePage();
      default:
        return ProjectSummaryContent();
    }
  }

  Widget heading(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: devText,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: devMuted)),
        ],
      ),
    );
  }

  Widget panel({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: devBorder),
        boxShadow: [
          BoxShadow(
            color: devPurple.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget metric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: devBorder),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: devText, size: 21),
          ),
          const SizedBox(height: 17),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: devText,
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: devMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget activity(IconData icon, String title, String subtitle, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: devText),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
    );
  }

  

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: devMuted)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: devText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget filesPage() {
    final files = [
      ['main.dart', 'Application entry point', Icons.code],
      ['login_screen.dart', 'Authentication interface', Icons.login],
      ['dashboard_screen.dart', 'Dashboard UI', Icons.dashboard_outlined],
      ['api_service.dart', 'API integration', Icons.cloud_outlined],
      ['README.md', 'Project documentation', Icons.description_outlined],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('Project Files', 'Browse important files in your project.'),
        panel(
          child: Column(
            children: files.map((file) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: devLilac.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(file[2] as IconData, color: devText),
                ),
                title: Text(file[0] as String),
                subtitle: Text(file[1] as String),
                trailing: const Icon(Icons.chevron_right, color: devMuted),
                onTap: () => showMessage(
                  '${file[0]} is sample project data. Connect your file storage to open real files.',
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget taskPage({required bool completed}) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Text('Please log in to view your tasks.');
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('assignedTo', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error loading tasks: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        final visibleTasks = docs.where((doc) {
          final status = doc.data()['status'] ?? 'Assigned';
          return completed ? status == 'Completed' : status != 'Completed';
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading(
              completed ? 'Completed Tasks' : 'Assigned to You',
              completed
                  ? 'Tasks you have completed.'
                  : 'Tasks and bug fixes assigned by your Team Leader.',
            ),
            if (visibleTasks.isEmpty)
              panel(
                child: Text(
                  completed
                      ? 'No completed tasks yet.'
                      : 'No tasks assigned to you yet.',
                ),
              ),
            ...visibleTasks.map((doc) {
              final task = doc.data();
              final status = task['status'] ?? 'Assigned';

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'] ?? 'Untitled task',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: devText,
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        'Task Description',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: devText,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        task['description'] ?? 'No description provided.',
                        style: const TextStyle(color: devMuted, height: 1.5),
                      ),
                      const Divider(height: 28),

                      Text(
                        'Assigned by: ${task['assignedByEmail'] ?? 'Team Leader'}',
                      ),
                      const SizedBox(height: 6),
                      Text('Priority: ${task['priority'] ?? 'Medium'}'),
                      const SizedBox(height: 6),
                      Text('Status: $status'),

                      if (!completed) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: status == 'In Progress'
                                  ? null
                                  : () async {
                                      try {
                                        await doc.reference.update({
                                          'status': 'In Progress',
                                          'updatedAt':
                                              FieldValue.serverTimestamp(),
                                        });
                                      } catch (e) {
                                        if (mounted) {
                                          showMessage(
                                            'Could not start task: $e',
                                          );
                                        }
                                      }
                                    },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Task'),
                            ),

                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: status == 'Completed'
                                  ? null
                                  : () async {
                                      try {
                                        await doc.reference.update({
                                          'status': 'Completed',
                                          'completedAt':
                                              FieldValue.serverTimestamp(),
                                          'updatedAt':
                                              FieldValue.serverTimestamp(),
                                        });

                                        if (mounted) {
                                          showMessage(
                                            'Task completed successfully!',
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          showMessage(
                                            'Could not complete task: $e',
                                          );
                                        }
                                      }
                                    },
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Complete Task'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Task Completed Successfully!',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (task['completedAt'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Completed on: '
                            '${(task['completedAt'] as Timestamp).toDate().toLocal()}',
                            style: const TextStyle(color: devMuted),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void addTask() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Demo Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              setState(() {
                tasks.add({
                  'title': titleController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'priority': 'Medium',
                  'status': 'Pending',
                });
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) {
      titleController.dispose();
      descriptionController.dispose();
    });
  }

  Widget chatbotPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(
          'Developer Chatbot',
          'Ask questions while working on your project.',
        ),
        panel(
          child: Column(
            children: [
              Container(
                height: 320,
                alignment: Alignment.topLeft,
                child: ListView.builder(
                  itemCount: chatMessages.length,
                  itemBuilder: (context, index) {
                    final isUser = chatMessages[index].startsWith('You:');
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 520),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: isUser ? devLilac : devBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(chatMessages[index]),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: chatController,
                      decoration: const InputDecoration(
                        hintText: 'Ask about Flutter, tasks, or Git...',
                      ),
                      onSubmitted: (_) => sendChat(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: sendChat,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'This is a demo chatbot with simple local responses. Connect an AI service for real answers.',
          style: TextStyle(color: devMuted, fontSize: 12),
        ),
      ],
    );
  }

  
Future<void> sendChat() async {
  final question = chatController.text.trim();

  if (question.isEmpty || isChatLoading) return;

  setState(() {
    chatMessages.add('You: $question');
    chatController.clear();
    isChatLoading = true;
  });

  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': question}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (!mounted) return;

      setState(() {
        chatMessages.add(
          'Assistant: ${data['answer'] ?? 'No answer received.'}',
        );
      });
    } else {
      throw Exception(data['error'] ?? 'Server error');
    }
  } catch (e) {
    if (!mounted) return;

    setState(() {
      chatMessages.add('Assistant: Unable to connect to AI. Error: $e');
    });
  } finally {
    if (mounted) {
      setState(() => isChatLoading = false);
    }
  }
}


  Widget gitPage({required bool branch}) {
    final commands = branch
        ? [
            ['List branches', 'git branch'],
            ['Create a branch', 'git branch feature-name'],
            ['Switch branch', 'git switch feature-name'],
            ['Create and switch', 'git switch -c feature-name'],
            ['Delete a local branch', 'git branch -d feature-name'],
          ]
        : [
            ['Initialize repository', 'git init'],
            ['Check repository status', 'git status'],
            ['Clone a repository', 'git clone <repository-url>'],
            ['Stage changes', 'git add .'],
            ['Commit changes', 'git commit -m "Your message"'],
            ['Push changes', 'git push'],
            ['Pull latest changes', 'git pull'],
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(
          branch ? 'Git Branch Commands' : 'Git Repository Commands',
          branch
              ? 'Useful commands for creating and managing branches.'
              : 'Common commands for managing your project repository.',
        ),
        panel(
          child: Column(
            children: commands.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: devBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.terminal, color: devPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item[0],
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: devText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            item[1],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: devMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copy command',
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: item[1]));
                        if (mounted) {
                          showMessage('Command copied: ${item[0]}');
                        }
                      },
                      icon: const Icon(Icons.copy_rounded),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget profilePage() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please log in to view your profile.'));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text('Error loading profile.');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Registration details not found.');
        }

        final data = snapshot.data!.data()!;

        // Change these keys if your registration page
        // uses different Firestore field names.
        final name =
            data['name'] ??
            data['fullName'] ??
            data['username'] ??
            'Not provided';

        final email = data['email'] ?? user.email ?? 'Not provided';
        final role = data['role'] ?? 'Developer';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading('My Profile', 'Your registration information'),
            panel(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: devLilac,
                    child: Icon(Icons.person, size: 48, color: devText),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: devText,
                    ),
                  ),
                  Text(
                    email.toString(),
                    style: const TextStyle(color: devMuted),
                  ),
                  const Divider(height: 32),

                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Full Name'),
                    subtitle: Text(name.toString()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(email.toString()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.work_outline),
                    title: const Text('Role'),
                    subtitle: Text(role.toString()),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => updateProfile(data),
                      icon: const Icon(Icons.edit),
                      label: const Text('Update Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: devPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(
      text: (data['name'] ?? data['fullName'] ?? data['username'] ?? '')
          .toString(),
    );

    final emailController = TextEditingController(
      text: user.email ?? (data['email'] ?? '').toString(),
    );

    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Change Password (optional)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final email = emailController.text.trim();

              if (name.isEmpty || email.isEmpty || !email.contains('@')) {
                showMessage('Enter a valid name and email.');
                return;
              }

              try {
                final updates = <String, dynamic>{
                  'email': email,
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                if (data.containsKey('fullName')) {
                  updates['fullName'] = name;
                } else if (data.containsKey('username')) {
                  updates['username'] = name;
                } else {
                  updates['name'] = name;
                }

                // Update Firebase Authentication email.
                if (email != user.email) {
                  await user.verifyBeforeUpdateEmail(email);
                }

                // Update the Firestore user document.
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update(updates);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                if (mounted) {
                  showMessage(
                    email != user.email
                        ? 'Profile saved. Verify your new email address.'
                        : 'Profile updated successfully!',
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (mounted) {
                  showMessage(
                    e.code == 'requires-recent-login'
                        ? 'Please log out and log in again before changing email.'
                        : 'Email update failed: ${e.message ?? e.code}',
                  );
                }
              } catch (e) {
                if (mounted) {
                  showMessage('Could not update profile: $e');
                }
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );

    nameController.dispose();
    emailController.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}



Widget ProjectSummaryContent(){
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Text('Please log in to view your projects.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Project Summary',
          subtitle: 'View projects assigned to you by the Admin.',
        ),

        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('projects')
              .where('developerIds', isEqualTo: user.uid)
              .snapshots(),

          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return DashboardCard(
                child: Text(
                  'Unable to load projects: ${snapshot.error}',
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final projects = snapshot.data?.docs ?? [];

            if (projects.isEmpty) {
              return const DashboardCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open_rounded,
                      size: 45,
                      color: tlMuted,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No projects assigned yet.',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: tlText,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Projects assigned by the Admin will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: tlMuted),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: projects.map((projectDocument) {
                final data = projectDocument.data();

                final name =
                    (data['name'] ?? 'Unnamed Project').toString();

                final description =
                    (data['description'] ?? 'No description available')
                        .toString();

                final repositoryUrl =
                    (data['repositoryUrl'] ?? '').toString();

                final status =
                    (data['status'] ?? 'Active').toString();

                final createdAt = data['createdAt'];

                String createdDate = 'Not available';

                if (createdAt is Timestamp) {
                  final date = createdAt.toDate();
                  createdDate =
                      '${date.day}/${date.month}/${date.year}';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: DashboardCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Project name and status
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: tlLilac,
                              child: Icon(
                                Icons.folder_rounded,
                                color: tlText,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: tlText,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(status),
                              backgroundColor: tlLilac,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Project description
                        const Text(
                          'Project Description',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: tlText,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          description,
                          style: const TextStyle(
                            height: 1.6,
                            fontSize: 13,
                            color: tlMuted,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFF0EFF5)),

                        // GitHub repository
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Icon(
                              Icons.code_rounded,
                              color: tlPurple,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'GitHub Repository',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: tlText,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        if (repositoryUrl.isNotEmpty)
                          InkWell(
                            onTap: () async {
                              final uri = Uri.tryParse(repositoryUrl);

                              if (uri != null &&
                                  (uri.scheme == 'https' ||
                                      uri.scheme == 'http') &&
                                  uri.host.isNotEmpty) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid repository URL'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              repositoryUrl,
                              style: const TextStyle(
                                color: Color(0xFF7653B6),
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        else
                          const Text(
                            'No repository URL provided.',
                            style: TextStyle(color: tlMuted),
                          ),

                        const SizedBox(height: 18),

                        // Additional project details
                        const Divider(color: Color(0xFFF0EFF5)),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Created on',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: tlMuted,
                                  ),
                                ),
                              ),
                              Text(
                                createdDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: tlText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

