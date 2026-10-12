
import 'package:flutter/material.dart';
import 'developer_theme.dart';
import 'developer_content.dart';
import 'loginpage.dart';

class DeveloperDashboard extends StatefulWidget {
  const DeveloperDashboard({super.key});

  @override
  State<DeveloperDashboard> createState() => _DeveloperDashboardState();
}

class _DeveloperDashboardState extends State<DeveloperDashboard> {
  String selectedPage = 'Progress';
  bool projectExpanded = true;
  bool tasksExpanded = true;
  bool gitExpanded = true;

  @override
  void _signOut() {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => const LoginPage(),
    ),
    (route) => false,
  );
}


  void openPage(String page) {
    setState(() => selectedPage = page);
  }

  Widget menuItem(
    String title,
    IconData icon, {
    String? page,
    int indent = 0,
  }) {
    final active = selectedPage == (page ?? title);

    return Padding(
      padding: EdgeInsets.only(left: indent == 0 ? 10 : 24, right: 10),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        selected: active,
        selectedTileColor: devLilac.withValues(alpha: 0.55),
        leading: Icon(
          icon,
          size: indent == 0 ? 21 : 18,
          color: active ? devText : devMuted,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: active ? devText : devMuted,
            fontSize: indent == 0 ? 14 : 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: () => openPage(page ?? title),
      ),
    );
  }

  Widget expandableMenu({
    required String title,
    required IconData icon,
    required bool expanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListTile(
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: Icon(icon, color: devMuted, size: 21),
            title: Text(
              title,
              style: const TextStyle(
                color: devText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: devMuted,
            ),
            onTap: onToggle,
          ),
        ),
        if (expanded) ...children,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 255,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: devBorder)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 24, 16, 22),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [devPink, devLilac, devBlue],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.code_rounded,
                            color: devText,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CodeAtlas',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: devText,
                                ),
                              ),
                              Text(
                                'Developer workspace',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: devMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 10, 8),
                    child: Text(
                      'WORKSPACE',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: devMuted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        expandableMenu(
                          title: 'View Project',
                          icon: Icons.folder_open_rounded,
                          expanded: projectExpanded,
                          onToggle: () => setState(
                            () => projectExpanded = !projectExpanded,
                          ),
                          children: [
                            menuItem('Summary', Icons.dashboard_outlined),
                            menuItem('Files', Icons.folder_copy_outlined),
                            menuItem('Bugs', Icons.bug_report_outlined),
                          ],
                        ),
                        expandableMenu(
                          title: 'Tasks',
                          icon: Icons.task_alt_rounded,
                          expanded: tasksExpanded,
                          onToggle: () => setState(
                            () => tasksExpanded = !tasksExpanded,
                          ),
                          children: [
                            menuItem('Assigned', Icons.assignment_outlined),
                            menuItem('Completed', Icons.check_circle_outline),
                          ],
                        ),
                        menuItem('Chatbot', Icons.smart_toy_outlined),
                        expandableMenu(
                          title: 'Git Commands',
                          icon: Icons.terminal_rounded,
                          expanded: gitExpanded,
                          onToggle: () => setState(
                            () => gitExpanded = !gitExpanded,
                          ),
                          children: [
                            menuItem('Repo', Icons.storage_outlined),
                            menuItem('Branch', Icons.account_tree_outlined),
                          ],
                        ),
                        menuItem('Progress', Icons.trending_up_rounded),
                        menuItem('My Profile', Icons.person_outline_rounded),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [devPink, devLilac, devBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: devText),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Developer',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: devText,
                                ),
                              ),
                              Text(
                                'Team workspace',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: devText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: devBorder)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedPage,
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                  color: devText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Manage your work and build with confidence.',
                                style: TextStyle(color: devMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: devMuted,
                        ),
                        const SizedBox(width: 18),
                        const CircleAvatar(
                          backgroundColor: devLilac,
                          child: Icon(Icons.person, color: devText),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(26),
                      child: DeveloperPageContent(page: selectedPage),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
