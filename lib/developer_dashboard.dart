
import 'package:flutter/material.dart';
import 'developer_theme.dart';
import 'developer_content.dart';
import 'loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chatbot_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'project_files_page.dart';

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
 
  Future <void> logout() async{
      await FirebaseAuth.instance.signOut();
  }

  
  @override
  Widget build(BuildContext context) {

  final user = FirebaseAuth.instance.currentUser;
  final username = user?.email;

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
                        Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color.fromRGBO(231, 198, 255, 1), Color.fromRGBO(187, 208, 255, 1)],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: IconButton(
                   icon: const Icon(Icons.logout),
                   color: const Color(0xFF7653B6),
                   tooltip: 'Sign Out',
                   onPressed: logout
              )
          ),
                      ],
                    ),
                  ),
             Expanded(
  child: selectedPage == 'Chatbot'
      ? const ChatbotScreen()
      : selectedPage == 'Files'
          ? const DeveloperAssignedProjectsScreen()
          : SingleChildScrollView(
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





class DeveloperAssignedProjectsScreen extends StatelessWidget {
  const DeveloperAssignedProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Please log in to view your project files.'),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('projects')
          .where('developerIds', isEqualTo: user.uid)
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading projects: ${snapshot.error}'),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.folder_open_rounded,
                  size: 55,
                  color: devMuted,
                ),
                SizedBox(height: 12),
                Text(
                  'No projects assigned to you yet.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: devText,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: projects.length,

          itemBuilder: (context, index) {
            final project = projects[index];
            final data = project.data();

            final projectName =
                (data['name'] ?? 'Unnamed Project').toString();

            final description =
                (data['description'] ?? 'No description available')
                    .toString();

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 16),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: devBorder),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: devLilac,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.folder_rounded,
                            color: devText,
                            size: 25,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Text(
                            projectName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: devText,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: devMuted,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectFilesPage(
                                projectId: project.id,
                                projectName: projectName,
                              ),
                            ),
                          );
                        },

                        icon: const Icon(Icons.folder_open_rounded),
                        label: const Text('View Project Files'),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: devLilac,
                          foregroundColor: devText,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
