
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'developer_theme.dart';

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
        return summaryPage();
      case 'Files':
        return filesPage();
      case 'Bugs':
        return bugsPage();
      case 'Assigned':
        return taskPage(completed: false);
      case 'Completed':
        return taskPage(completed: true);
      case 'Chatbot':
        return chatbotPage();
      case 'Repo':
        return gitPage(branch: false);
      case 'Branch':
        return gitPage(branch: true);
      case 'My Profile':
        return profilePage();
      case 'Progress':
      default:
        return progressPage();
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

  Widget metricGrid() {
    final items = [
      ['Assigned Tasks', '${tasks.where((t) => t['status'] != 'Completed').length}', Icons.assignment_outlined, devPink],
      ['Completed', '${tasks.where((t) => t['status'] == 'Completed').length}', Icons.check_circle_outline, devLilac],
      ['Project Progress', '68%', Icons.trending_up_rounded, devPeriwinkle],
      ['Open Bugs', '4', Icons.bug_report_outlined, devBlue],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 850
            ? 4
            : constraints.maxWidth > 520
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 175,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return metric(
              item[0] as String,
              item[1] as String,
              item[2] as IconData,
              item[3] as Color,
            );
          },
        );
      },
    );
  }

  Widget progressPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(
          'Developer Overview',
          'Welcome back! Here is your project activity at a glance.',
        ),
        metricGrid(),
        const SizedBox(height: 24),
        panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Project Progress',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: devText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'CodeAtlas web application',
                style: TextStyle(color: devMuted),
              ),
              const SizedBox(height: 18),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Overall completion'),
                  Text('68%', style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const LinearProgressIndicator(
                  value: 0.68,
                  minHeight: 10,
                  backgroundColor: devBackground,
                  color: devPurple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: devText,
                ),
              ),
              const SizedBox(height: 16),
              activity(Icons.task_alt, 'Task assigned', 'Create login page', devPink),
              activity(Icons.code, 'Git workflow', 'Review your branch before merging', devLilac),
              activity(Icons.bug_report, 'Bug tracking', 'Check the open issues', devBlue),
            ],
          ),
        ),
      ],
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

  Widget summaryPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('Project Summary', 'Understand the project you are working on.'),
        panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CodeAtlas — Project Learning and Management',
                style: TextStyle(
                  color: devText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'A workspace for managing project requirements, tasks, files, bugs, and team collaboration.',
                style: TextStyle(color: devMuted, height: 1.6),
              ),
              const Divider(height: 32),
              const Text('Project Details', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              detailRow('Project Manager', 'Project Admin'),
              detailRow('Team Leader', 'Team Leader'),
              detailRow('Your Role', 'Developer'),
              detailRow('Status', 'In Progress'),
              detailRow('Technology', 'Flutter / Dart'),
            ],
          ),
        ),
      ],
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

  Widget bugsPage() {
    final bugs = [
      ['BUG-101', 'Login button does not respond', 'High', 'Open'],
      ['BUG-102', 'Dashboard spacing issue', 'Medium', 'In Progress'],
      ['BUG-103', 'Profile image alignment', 'Low', 'Open'],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('Project Bugs', 'Review reported bugs and their current status.'),
        panel(
          child: Column(
            children: bugs.map((bug) {
              return Card(
                elevation: 0,
                color: devBackground,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${bug[0]} · ${bug[1]}',
                              style: const TextStyle(
                                color: devText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(bug[2], style: const TextStyle(color: devMuted)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: bug[3],
                        decoration: const InputDecoration(
                          labelText: 'Bug status',
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Open', child: Text('Open')),
                          DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                          DropdownMenuItem(value: 'Resolved', child: Text('Resolved')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => bug[3] = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget taskPage({required bool completed}) {
    final visibleTasks = tasks
        .where((task) => completed
            ? task['status'] == 'Completed'
            : task['status'] != 'Completed')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(
          completed ? 'Completed Tasks' : 'Assigned Tasks',
          completed
              ? 'Review tasks that have been completed.'
              : 'Check your tasks and update their status.',
        ),
        if (!completed)
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: addTask,
              icon: const Icon(Icons.add),
              label: const Text('Add demo task'),
            ),
          ),
        const SizedBox(height: 14),
        if (visibleTasks.isEmpty)
          panel(
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No tasks in this section yet.'),
              ),
            ),
          )
        else
          ...visibleTasks.map((task) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assignment_outlined, color: devPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            task['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: devText,
                            ),
                          ),
                        ),
                        Text(task['priority']!),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      task['description']!,
                      style: const TextStyle(color: devMuted),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: task['status'],
                      decoration: const InputDecoration(labelText: 'Task status'),
                      items: const [
                        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                        DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => task['status'] = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
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
        heading('Developer Chatbot', 'Ask questions while working on your project.'),
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

  void sendChat() {
    final question = chatController.text.trim();
    if (question.isEmpty) return;

    final lower = question.toLowerCase();
    String reply;

    if (lower.contains('git') || lower.contains('branch')) {
      reply = 'Try git status to inspect your changes, git branch to list branches, and git switch -c feature-name to create and switch to a branch.';
    } else if (lower.contains('flutter')) {
      reply = 'For Flutter checks, run flutter pub get, flutter analyze, and flutter run. Read the first error reported by the terminal.';
    } else if (lower.contains('task')) {
      reply = 'Open Tasks → Assigned to review your current tasks and update their status.';
    } else if (lower.contains('bug') || lower.contains('error')) {
      reply = 'Reproduce the issue, read the complete error message, identify the affected file and line, then test your fix.';
    } else {
      reply = 'I can help with basic Flutter, Git, tasks, and debugging questions. For project-specific answers, connect your project knowledge or an AI service.';
    }

    setState(() {
      chatMessages.add('You: $question');
      chatMessages.add('Assistant: $reply');
      chatController.clear();
    });
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
                        await Clipboard.setData(
                          ClipboardData(text: item[1]),
                        );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('My Profile', 'Your developer workspace information.'),
        panel(
          child: const Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: devLilac,
                child: Icon(Icons.person, color: devText, size: 42),
              ),
              SizedBox(height: 14),
              Text(
                'Developer',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: devText,
                ),
              ),
              Text('developer@example.com', style: TextStyle(color: devMuted)),
              Divider(height: 32),
              ListTile(
                leading: Icon(Icons.work_outline, color: devPurple),
                title: Text('Role'),
                subtitle: Text('Software Developer'),
              ),
              ListTile(
                leading: Icon(Icons.groups_outlined, color: devPurple),
                title: Text('Team'),
                subtitle: Text('Development Team'),
              ),
              ListTile(
                leading: Icon(Icons.folder_outlined, color: devPurple),
                title: Text('Current project'),
                subtitle: Text('CodeAtlas'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
