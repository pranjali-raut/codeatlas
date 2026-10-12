import 'package:flutter/material.dart';
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
        'Bugs' => const ProjectBugsContent(),
        'Schedule' => const ScheduleContent(),
        'Team Leader' => const TeamLeaderProfileContent(),
        'Team Members' => const TeamMembersContent(),
        _ => ProgressContent(onNavigate: onNavigate),
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
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: tlMuted,
            ),
          ),
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
          Text(
            note,
            style: const TextStyle(fontSize: 11, color: tlMuted),
          ),
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

class AssignTaskContent extends StatefulWidget {
  const AssignTaskContent({super.key});

  @override
  State<AssignTaskContent> createState() => _AssignTaskContentState();
}

class _AssignTaskContentState extends State<AssignTaskContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String assignee = 'Select team member';
  String priority = 'Medium';
  DateTime? dueDate;
  final List<String> assignedTasks = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) setState(() => dueDate = date);
  }

  void _assignTask() {
    if (!_formKey.currentState!.validate()) return;

    if (assignee == 'Select team member') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a team member.')),
      );
      return;
    }

    setState(() {
      assignedTasks.insert(0, _titleController.text.trim());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task added to this demo dashboard.')),
    );

    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      assignee = 'Select team member';
      priority = 'Medium';
      dueDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Enter a task title'
                          : null,
                  decoration: _inputDecoration('e.g. Build login screen'),
                ),
                const SizedBox(height: 17),
                _label('Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    'Describe the task, requirements and expected result',
                  ),
                ),
                const SizedBox(height: 17),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final narrow = constraints.maxWidth < 500;

                    final memberField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Assign to'),
                        DropdownButtonFormField<String>(
                          value: assignee,
                          isExpanded: true,
                          decoration: _inputDecoration(''),
                          items: [
                            'Select team member',
                            'Aarav Sharma',
                            'Ananya Patil',
                            'Rohan Desai',
                            'Priya Shah',
                          ].map((name) {
                            return DropdownMenuItem(
                              value: name,
                              child: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => assignee = value);
                            }
                          },
                        ),
                      ],
                    );

                    final priorityField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Priority'),
                        DropdownButtonFormField<String>(
                          value: priority,
                          decoration: _inputDecoration(''),
                          items: ['Low', 'Medium', 'High', 'Urgent']
                              .map((value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => priority = value);
                            }
                          },
                        ),
                      ],
                    );

                    if (narrow) {
                      return Column(
                        children: [
                          memberField,
                          const SizedBox(height: 16),
                          priorityField,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: memberField),
                        const SizedBox(width: 16),
                        Expanded(child: priorityField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 17),
                _label('Due date'),
                InkWell(
                  onTap: _chooseDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: _inputDecoration(''),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 18,
                          color: tlMuted,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          dueDate == null
                              ? 'Choose a deadline'
                              : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: tlText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _assignTask,
                    icon: const Icon(Icons.add_task_rounded, size: 18),
                    label: const Text('Assign Task'),
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
        if (assignedTasks.isNotEmpty) ...[
          const SizedBox(height: 20),
          DashboardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tasks added in this session',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: tlText,
                  ),
                ),
                const SizedBox(height: 12),
                ...assignedTasks.map(
                  (task) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: tlLilac,
                      child: Icon(Icons.assignment, color: tlText),
                    ),
                    title: Text(task),
                    subtitle: Text('$assignee • $priority priority'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

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
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 14,
    ),
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
                  Chip(
                    label: Text('In progress'),
                    backgroundColor: tlLilac,
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'A workspace that helps new developers understand company '
                'projects, complete assigned tasks and track their learning.',
                style: TextStyle(
                  height: 1.7,
                  fontSize: 13,
                  color: tlMuted,
                ),
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

class ProjectFilesContent extends StatelessWidget {
  const ProjectFilesContent({super.key});

  @override
  Widget build(BuildContext context) {
    const files = [
      ('README.md', 'Project documentation', Icons.description_outlined),
      ('requirements.pdf', 'Project requirements', Icons.picture_as_pdf_outlined),
      ('api_documentation.json', 'API reference', Icons.data_object_rounded),
      ('ui_design.fig', 'UI/UX design reference', Icons.design_services_outlined),
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
          'These are sample file entries. Connect your storage service to display actual uploaded project files.',
          style: TextStyle(fontSize: 11, color: tlMuted),
        ),
      ],
    );
  }
}

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
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF0EFF5)),
                  ),
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
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(
                                  status,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ))
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

class ScheduleContent extends StatelessWidget {
  const ScheduleContent({super.key});

  @override
  Widget build(BuildContext context) {
    const events = [
      ('10:00 AM', 'Daily team stand-up', 'Team meeting', tlLilac),
      ('12:30 PM', 'Review open bugs', 'Quality review', tlBlue),
      ('03:00 PM', 'Project progress review', 'Project milestone', tlPink),
      ('Tomorrow', 'Sprint planning', 'Planning session', tlPeriwinkle),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Team Schedule',
          subtitle: 'Keep meetings, reviews and deadlines organized.',
        ),
        const DashboardCard(
          child: Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 34, color: tlText),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your team calendar',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: tlText,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Upcoming events and project milestones',
                      style: TextStyle(fontSize: 11, color: tlMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DashboardCard(
          child: Column(
            children: events.map((event) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: event.$4,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.event_note_rounded,
                    color: tlText,
                  ),
                ),
                title: Text(
                  event.$2,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: tlText,
                  ),
                ),
                subtitle: Text(
                  '${event.$1} • ${event.$3}',
                  style: const TextStyle(fontSize: 11, color: tlMuted),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class TeamLeaderProfileContent extends StatelessWidget {
  const TeamLeaderProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Team Leader',
          subtitle: 'Your workspace profile and responsibilities.',
        ),
        const DashboardCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: tlLilac,
                child: Icon(Icons.person, size: 48, color: tlText),
              ),
              SizedBox(height: 15),
              Text(
                'Team Leader',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: tlText,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Project coordination and delivery',
                style: TextStyle(fontSize: 12, color: tlMuted),
              ),
              SizedBox(height: 25),
              Divider(color: Color(0xFFF0EFF5)),
              _ProfileLine(
                icon: Icons.assignment_turned_in_outlined,
                title: 'Assign and review tasks',
              ),
              _ProfileLine(
                icon: Icons.groups_outlined,
                title: 'Coordinate team members',
              ),
              _ProfileLine(
                icon: Icons.bug_report_outlined,
                title: 'Monitor bugs and blockers',
              ),
              _ProfileLine(
                icon: Icons.timeline_rounded,
                title: 'Track project milestones',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileLine extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ProfileLine({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF8068CE)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: tlText),
      ),
    );
  }
}

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
                        style: const TextStyle(
                          color: tlMuted,
                          fontSize: 11,
                        ),
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
