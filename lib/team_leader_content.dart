import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'team_leader_dashboard.dart';

class TeamLeaderPageContent extends StatelessWidget {
  final String page;
  final ValueChanged<String> onNavigate;

  const TeamLeaderPageContent({
    super.key,
    required this.page,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(26),
      child: switch (page) {
        'Assign Task' => const AssignTaskContent(),
        'Summary' => const ProjectSummaryContent(),
        'Files' => const ProjectFilesContent(),
        'Team Leader' => const TeamLeaderProfileContent(),
        'Team Members' => const TeamMembersContent(),
        _ => const ProjectSummaryContent(),
      },
    );
  }
}

class SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
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
              color: tlText,
            ),
          ),
          const SizedBox(height: 7),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: tlMuted)),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const DashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFF0EFF5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF292743).withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String note;
  final IconData icon;
  final Color color;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.note,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: tlMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: tlText, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            value,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: tlText,
            ),
          ),
          const SizedBox(height: 5),
          Text(note, style: const TextStyle(fontSize: 11, color: tlMuted)),
        ],
      ),
    );
  }
}

class ProgressContent extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const ProgressContent({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Team Overview',
          subtitle: 'Track project delivery and your team’s current workload.',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth > 1000
                ? 4
                : constraints.maxWidth > 560
                ? 2
                : 1;

            return GridView.count(
              crossAxisCount: count,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: constraints.maxWidth < 560 ? 2.1 : 1.55,
              children: const [
                MetricCard(
                  label: 'Active Tasks',
                  value: '24',
                  note: 'Across all team members',
                  icon: Icons.assignment_outlined,
                  color: tlPink,
                ),
                MetricCard(
                  label: 'Completed',
                  value: '68%',
                  note: 'Tasks completed',
                  icon: Icons.task_alt_rounded,
                  color: tlLilac,
                ),
                MetricCard(
                  label: 'Open Bugs',
                  value: '08',
                  note: 'Require attention',
                  icon: Icons.bug_report_outlined,
                  color: tlBlue,
                ),
                MetricCard(
                  label: 'Team Members',
                  value: '06',
                  note: 'In this workspace',
                  icon: Icons.groups_rounded,
                  color: tlPeriwinkle,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Project Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: tlText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Developer Onboarding Platform',
                style: TextStyle(fontSize: 12, color: tlMuted),
              ),
              const SizedBox(height: 19),
              const LinearProgressIndicator(
                value: 0.68,
                minHeight: 9,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                backgroundColor: Color(0xFFF0EDF8),
                valueColor: AlwaysStoppedAnimation(tlPurple),
              ),
              const SizedBox(height: 9),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '68% completed',
                    style: TextStyle(
                      color: tlText,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Target: 85%',
                    style: TextStyle(fontSize: 11, color: tlMuted),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => onNavigate('Assign Task'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Assign a task'),
                style: FilledButton.styleFrom(
                  backgroundColor: tlText,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Team Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: tlText,
                ),
              ),
              SizedBox(height: 16),
              ActivityRow(
                icon: Icons.check_circle_outline,
                color: Color(0xFF8C79D6),
                title: 'Login screen completed',
                detail: 'A team member moved the task to completed',
                time: 'Today',
              ),
              Divider(height: 24, color: Color(0xFFF0EFF5)),
              ActivityRow(
                icon: Icons.bug_report_outlined,
                color: Color(0xFFE89A9A),
                title: 'New bug reported',
                detail: 'Registration form validation issue',
                time: 'Today',
              ),
              Divider(height: 24, color: Color(0xFFF0EFF5)),
              ActivityRow(
                icon: Icons.assignment_outlined,
                color: Color(0xFF7E9DDD),
                title: 'API integration assigned',
                detail: 'Task assigned to a developer',
                time: 'Yesterday',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final String time;

  const ActivityRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(icon, size: 19, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: tlText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(fontSize: 11, color: tlMuted),
              ),
            ],
          ),
        ),
        Text(time, style: const TextStyle(fontSize: 10, color: tlMuted)),
      ],
    );
  }
}

// ============================================================
// ASSIGN TASK - FIRESTORE INTEGRATION
// ============================================================

class AssignTaskContent extends StatefulWidget {
  const AssignTaskContent({super.key});

  @override
  State<AssignTaskContent> createState() => _AssignTaskContentState();
}

class _AssignTaskContentState extends State<AssignTaskContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? assigneeId;
  String priority = 'Medium';
  DateTime? dueDate;
  bool isAssigning = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _chooseDate() async {
    final today = DateUtils.dateOnly(DateTime.now());

    final date = await showDatePicker(
      context: context,
      initialDate: dueDate ?? today,
      firstDate: today,
      lastDate: DateTime(2035),
    );

    if (date != null && mounted) {
      setState(() => dueDate = date);
    }
  }

  Future<void> _assignTask() async {
    if (!_formKey.currentState!.validate()) return;

    final leader = FirebaseAuth.instance.currentUser;

    if (leader == null) {
      _showMessage('Please log in again.');
      return;
    }

    if (assigneeId == null) {
      _showMessage('Please select a team member.');
      return;
    }

    setState(() => isAssigning = true);

    try {
      final db = FirebaseFirestore.instance;

      // Verify that the selected developer exists and belongs
      // to the currently logged-in Team Leader.
      final developerSnapshot = await db
          .collection('users')
          .doc(assigneeId)
          .get();

      if (!developerSnapshot.exists) {
        throw Exception('Selected developer was not found.');
      }

      final developer = developerSnapshot.data()!;

      if (developer['role'] != 'Developer' ||
          developer['teamLeaderId'] != leader.uid) {
        throw Exception(
          'You can assign tasks only to developers in your team.',
        );
      }

      // Get the actual team document ID.
      final teamSnapshot = await db
          .collection('teams')
          .where('teamLeaderId', isEqualTo: leader.uid)
          .limit(1)
          .get();

      if (teamSnapshot.docs.isEmpty) {
        throw Exception(
          'No team found. Please add members in Manage Team first.',
        );
      }

      final teamId = teamSnapshot.docs.first.id;

      // Create a persistent task document.
      await db.collection('tasks').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'assignedTo': assigneeId,
        'developerId': assigneeId,
        'assignedBy': leader.uid,
        'teamId': teamId,
        'priority': priority,
        'status': 'Assigned',
        'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _titleController.clear();
        _descriptionController.clear();
        assigneeId = null;
        priority = 'Medium';
        dueDate = null;
      });

      _showMessage('Task assigned successfully!');
    } catch (e) {
      _showMessage('Unable to assign task: $e');
    } finally {
      if (mounted) {
        setState(() => isAssigning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leader = FirebaseAuth.instance.currentUser;

    if (leader == null) {
      return const Text('Please log in to assign tasks.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Assign a Task',
          subtitle: 'Give your developers clear ownership and deadlines.',
        ),
        DashboardCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: tlText,
                  ),
                ),
                const SizedBox(height: 20),

                _label('Task title'),
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration('e.g. Build login screen'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a task title.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 17),

                _label('Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    'Describe requirements and expected result',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a task description.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 17),

                _label('Assign to'),

                // Dynamically load developers assigned to this leader.
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('teamLeaderId', isEqualTo: leader.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                        'Unable to load team members. Check Firestore rules.',
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final developers = snapshot.data!.docs
                        .where((doc) => doc.data()['role'] == 'Developer')
                        .toList();

                    if (developers.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No developers found in your team. '
                          'Add members in Manage Team first.',
                          style: TextStyle(color: tlMuted),
                        ),
                      );
                    }

                    final developerIds = developers
                        .map((doc) => doc.id)
                        .toSet();

                    return DropdownButtonFormField<String>(
                      value: developerIds.contains(assigneeId)
                          ? assigneeId
                          : null,
                      isExpanded: true,
                      decoration: _inputDecoration('Select team member'),
                      items: developers.map((doc) {
                        final data = doc.data();
                        final name = (data['name'] ?? 'Developer').toString();
                        final email = (data['email'] ?? '').toString();

                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(
                            email.isEmpty ? name : '$name ($email)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => assigneeId = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a team member.';
                        }
                        return null;
                      },
                    );
                  },
                ),

                const SizedBox(height: 17),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final priorityField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Priority'),
                        DropdownButtonFormField<String>(
                          value: priority,
                          isExpanded: true,
                          decoration: _inputDecoration(''),
                          items: const [
                            DropdownMenuItem(value: 'Low', child: Text('Low')),
                            DropdownMenuItem(
                              value: 'Medium',
                              child: Text('Medium'),
                            ),
                            DropdownMenuItem(
                              value: 'High',
                              child: Text('High'),
                            ),
                            DropdownMenuItem(
                              value: 'Urgent',
                              child: Text('Urgent'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => priority = value);
                            }
                          },
                        ),
                      ],
                    );

                    final dateField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Due date'),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _chooseDate,
                            icon: const Icon(Icons.calendar_month_outlined),
                            label: Text(
                              dueDate == null
                                  ? 'Choose a deadline'
                                  : '${dueDate!.day}/'
                                        '${dueDate!.month}/'
                                        '${dueDate!.year}',
                            ),
                          ),
                        ),
                      ],
                    );

                    if (constraints.maxWidth < 500) {
                      return Column(
                        children: [
                          priorityField,
                          const SizedBox(height: 16),
                          dateField,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: priorityField),
                        const SizedBox(width: 16),
                        Expanded(child: dateField),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isAssigning ? null : _assignTask,
                    icon: isAssigning
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add_task_rounded),
                    label: Text(isAssigning ? 'Assigning...' : 'Assign Task'),
                    style: FilledButton.styleFrom(
                      backgroundColor: tlText,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 22),

        const SectionHeading(
          title: 'Assigned Tasks',
          subtitle: 'View tasks assigned by you to your team members.',
        ),

        // Tasks are read from Firestore, so they remain after app restart.
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .where('assignedBy', isEqualTo: leader.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const DashboardCard(
                child: Text(
                  'Unable to load tasks. Check your Firestore rules.',
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final tasks = snapshot.data!.docs.toList();

            tasks.sort((a, b) {
              final aTime = a.data()['createdAt'];
              final bTime = b.data()['createdAt'];

              final aDate = aTime is Timestamp
                  ? aTime.toDate()
                  : DateTime(2000);

              final bDate = bTime is Timestamp
                  ? bTime.toDate()
                  : DateTime(2000);

              return bDate.compareTo(aDate);
            });

            if (tasks.isEmpty) {
              return const DashboardCard(
                child: Text(
                  'No tasks assigned yet.',
                  style: TextStyle(color: tlMuted),
                ),
              );
            }

            return DashboardCard(
              child: Column(
                children: tasks.map((doc) {
                  final task = doc.data();

                  final title = (task['title'] ?? 'Untitled task').toString();
                  final description = (task['description'] ?? '').toString();
                  final status = (task['status'] ?? 'Assigned').toString();
                  final taskPriority = (task['priority'] ?? 'Medium')
                      .toString();
                  final developerId = (task['assignedTo'] ?? '').toString();
                  final due = task['dueDate'];

                  final dueText = due is Timestamp
                      ? '${due.toDate().day}/'
                            '${due.toDate().month}/'
                            '${due.toDate().year}'
                      : 'No due date';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: tlLilac,
                      child: Icon(Icons.assignment_outlined, color: tlText),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: tlText,
                      ),
                    ),
                    subtitle: Text('Status: $status • Priority: $taskPriority'),
                    trailing: const Icon(Icons.chevron_right, color: tlMuted),
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: Text(title),
                            content: SingleChildScrollView(
                              child: Text(
                                'Description: $description\n\n'
                                'Developer ID: $developerId\n'
                                'Priority: $taskPriority\n'
                                'Status: $status\n'
                                'Due date: $dueText',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ============================================================
// EXISTING HELPER FUNCTIONS
// ============================================================

Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: tlText,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: tlMuted, fontSize: 12),
    filled: true,
    fillColor: const Color(0xFFFCFBFE),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFECEAF3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFECEAF3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: tlPurple, width: 1.5),
    ),
  );
}

// ============================================================
// PROJECT SUMMARY
// ============================================================

class ProjectSummaryContent extends StatelessWidget {
  const ProjectSummaryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Project Summary',
          subtitle: 'A quick view of the current project status.',
        ),
        const DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Developer Onboarding Platform',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: tlText,
                      ),
                    ),
                  ),
                  Chip(label: Text('In progress'), backgroundColor: tlLilac),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'A workspace that helps new developers understand company '
                'projects, complete assigned tasks and track their learning.',
                style: TextStyle(height: 1.7, fontSize: 13, color: tlMuted),
              ),
              SizedBox(height: 24),
              _SummaryLine(label: 'Team leader', value: 'You'),
              _SummaryLine(label: 'Project priority', value: 'High'),
              _SummaryLine(label: 'Target progress', value: '68%'),
              _SummaryLine(label: 'Current phase', value: 'Development'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth > 650 ? 3 : 1;

            return GridView.count(
              crossAxisCount: count,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: count == 1 ? 3.2 : 1.6,
              children: const [
                MetricCard(
                  label: 'Total tasks',
                  value: '32',
                  note: 'All project tasks',
                  icon: Icons.assignment_outlined,
                  color: tlPink,
                ),
                MetricCard(
                  label: 'Completed tasks',
                  value: '22',
                  note: 'Ready for review',
                  icon: Icons.check_circle_outline,
                  color: tlLilac,
                ),
                MetricCard(
                  label: 'Open bugs',
                  value: '08',
                  note: 'Pending fixes',
                  icon: Icons.bug_report_outlined,
                  color: tlBlue,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: tlMuted),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: tlText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROJECT FILES
// ============================================================

class ProjectFilesContent extends StatelessWidget {
  const ProjectFilesContent({super.key});

  @override
  Widget build(BuildContext context) {
    const files = [
      ('README.md', 'Project documentation', Icons.description_outlined),
      (
        'requirements.pdf',
        'Project requirements',
        Icons.picture_as_pdf_outlined,
      ),
      ('api_documentation.json', 'API reference', Icons.data_object_rounded),
      (
        'ui_design.fig',
        'UI/UX design reference',
        Icons.design_services_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Project Files',
          subtitle: 'Browse the documents and resources for this project.',
        ),
        DashboardCard(
          child: Column(
            children: files.map((file) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 5),
                leading: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: tlLilac,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(file.$3, color: tlText),
                ),
                title: Text(
                  file.$1,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: tlText,
                  ),
                ),
                subtitle: Text(
                  file.$2,
                  style: const TextStyle(fontSize: 11, color: tlMuted),
                ),
                trailing: IconButton(
                  tooltip: 'File options',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${file.$1}: demo file entry')),
                    );
                  },
                  icon: const Icon(Icons.more_horiz, color: tlMuted),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'These are sample file entries. Connect your storage service '
          'to display actual uploaded project files.',
          style: TextStyle(fontSize: 11, color: tlMuted),
        ),
      ],
    );
  }
}

// ============================================================
// BUG TRACKER
// ============================================================

class ProjectBugsContent extends StatefulWidget {
  const ProjectBugsContent({super.key});

  @override
  State<ProjectBugsContent> createState() => _ProjectBugsContentState();
}

class _ProjectBugsContentState extends State<ProjectBugsContent> {
  final List<Map<String, String>> bugs = [
    {
      'title': 'Registration form validation issue',
      'severity': 'High',
      'status': 'Open',
    },
    {
      'title': 'Dashboard layout overflows on small screen',
      'severity': 'Medium',
      'status': 'In progress',
    },
    {
      'title': 'Incorrect error message on login',
      'severity': 'Low',
      'status': 'Open',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Bug Tracker',
          subtitle: 'Review issues and monitor fixes with your developers.',
        ),
        DashboardCard(
          child: Column(
            children: bugs.map((bug) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF0EFF5))),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bug_report_outlined,
                      color: Color(0xFFD77B8A),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bug['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: tlText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Severity: ${bug['severity']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: tlMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: bug['status'],
                      underline: const SizedBox(),
                      items: ['Open', 'In progress', 'Resolved']
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(
                                status,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (status) {
                        if (status != null) {
                          setState(() => bug['status'] = status);
                        }
                      },
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
}
// ============================================================
// TEAM LEADER PROFILE
// ============================================================

class TeamLeaderProfileContent extends StatelessWidget {
  const TeamLeaderProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SectionHeading(
        title: 'Team Leader Profile',
        subtitle: 'Please log in to view your profile.',
      );
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
          return const Text('Unable to load your profile.');
        }

        final data = snapshot.data?.data() ?? {};

        final name = (data['name'] as String?)?.trim();
        final email = (data['email'] as String?)?.trim();
        final role = (data['role'] as String?)?.trim();

        final displayName =
            (name == null || name.isEmpty)
                ? (user.displayName ?? 'Team Leader')
                : name;

        final displayEmail =
            (email == null || email.isEmpty)
                ? (user.email ?? 'Email not available')
                : email;

        final displayRole =
            (role == null || role.isEmpty)
                ? 'Team Leader'
                : role;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(
              title: 'My Profile',
              subtitle: 'Your registered account information.',
            ),
            const SizedBox(height: 16),
            DashboardCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: tlLilac,
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'T',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: tlText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: tlText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    displayRole,
                    style: const TextStyle(
                      fontSize: 14,
                      color: tlMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  _ProfileLine(
                    icon: Icons.person_outline,
                    title: displayName,
                  ),
                  _ProfileLine(
                    icon: Icons.email_outlined,
                    title: displayEmail,
                  ),
                  _ProfileLine(
                    icon: Icons.work_outline,
                    title: displayRole,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Update Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8068CE),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final result =
                            await showDialog<Map<String, String>>(
                          context: context,
                          builder: (dialogContext) =>
                              _EditTeamLeaderProfileDialog(
                            initialName: displayName,
                            initialEmail: displayEmail,
                          ),
                        );

                        if (!context.mounted || result == null) {
                          return;
                        }

                        final newName = result['name']!;
                        final newEmail = result['email']!;

                        final currentUser =
                            FirebaseAuth.instance.currentUser;

                        if (currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please log in again.'),
                            ),
                          );
                          return;
                        }

                        try {
                          final oldEmail = currentUser.email ?? '';

                          // Save the name in Firestore.
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .update({
                            'name': newName,
                            'updatedAt': FieldValue.serverTimestamp(),
                          });

                          // Firebase requires email verification
                          // before completing an email change.
                          if (newEmail.toLowerCase() !=
                              oldEmail.toLowerCase()) {
                            await currentUser.verifyBeforeUpdateEmail(
                              newEmail,
                            );

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Name updated. Check your new email '
                                  'to verify the email change.',
                                ),
                              ),
                            );
                          } else {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Profile updated successfully!',
                                ),
                              ),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          if (!context.mounted) return;

                          final message =
                              e.code == 'requires-recent-login'
                                  ? 'Please log in again before changing '
                                      'your email.'
                                  : e.code == 'email-already-in-use'
                                      ? 'This email is already in use.'
                                      : 'Could not update email: '
                                          '${e.message}';

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Update failed: $e'),
                            ),
                          );
                        }
                      },
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
}

// ============================================================
// UPDATE PROFILE DIALOG
// Controllers are owned and disposed by this StatefulWidget.
// ============================================================

class _EditTeamLeaderProfileDialog extends StatefulWidget {
  final String initialName;
  final String initialEmail;

  const _EditTeamLeaderProfileDialog({
    required this.initialName,
    required this.initialEmail,
  });

  @override
  State<_EditTeamLeaderProfileDialog> createState() =>
      _EditTeamLeaderProfileDialogState();
}

class _EditTeamLeaderProfileDialogState
    extends State<_EditTeamLeaderProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialName,
    );

    _emailController = TextEditingController(
      text: widget.initialEmail,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    final form = _formKey.currentState;

    if (form == null || !form.validate()) {
      return;
    }

    Navigator.of(context).pop<Map<String, String>>({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Profile'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(email)) {
                    return 'Enter a valid email';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}

// ============================================================
// PROFILE INFORMATION ROW
// ============================================================

class _ProfileLine extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ProfileLine({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: const Color(0xFF8068CE),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: tlText,
        ),
      ),
    );
  }
}


// ============================================================
// TEAM MEMBERS
// ============================================================

class TeamMembersContent extends StatelessWidget {
  const TeamMembersContent({super.key});

  @override
  Widget build(BuildContext context) {
    const members = [
      ('Aarav Sharma', 'Frontend Developer', tlLilac),
      ('Ananya Patil', 'Backend Developer', tlBlue),
      ('Rohan Desai', 'Flutter Developer', tlPink),
      ('Priya Shah', 'QA Engineer', tlPeriwinkle),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Team Members',
          subtitle: 'Review your team and their roles.',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth > 900
                ? 3
                : constraints.maxWidth > 550
                ? 2
                : 1;

            return GridView.count(
              crossAxisCount: count,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: count == 1 ? 3.0 : 1.55,
              children: members.map((member) {
                return DashboardCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 27,
                        backgroundColor: member.$3,
                        child: Text(
                          member.$1.substring(0, 1),
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: tlText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        member.$1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: tlText,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        member.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: tlMuted, fontSize: 11),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
