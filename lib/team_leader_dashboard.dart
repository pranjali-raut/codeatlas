import 'package:flutter/material.dart';
import 'team_leader_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'developer_theme.dart';
import 'project_files_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color tlPink = Color(0xFFFFD6FF);
const Color tlLilac = Color(0xFFE7C6FF);
const Color tlPurple = Color(0xFFC8B6FF);
const Color tlPeriwinkle = Color(0xFFB8C0FF);
const Color tlBlue = Color(0xFFBBD0FF);
const Color tlBackground = Color(0xFFF8F7FC);
const Color tlText = Color(0xFF292743);
const Color tlMuted = Color(0xFF85849A);

class TeamLeaderDashboard extends StatefulWidget {
  const TeamLeaderDashboard({super.key});

  @override
  State<TeamLeaderDashboard> createState() =>
      _TeamLeaderDashboardState();
}

class _TeamLeaderDashboardState extends State<TeamLeaderDashboard> {
  String selectedPage = 'Progress';
  bool projectExpanded = true;

 
void navigateTo(String page) {
  if (page == 'Files') {
    _openProjectFiles();
    return;
  }

  setState(() => selectedPage = page);
}


Future<void> _openProjectFiles() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return;
  }

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('teamLeaderId', isEqualTo: user.uid)
        .get();

    if (!mounted) return;

    if (snapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No projects are assigned to you yet.'),
        ),
      );
      return;
    }

    final selectedProject =
        await showDialog<QueryDocumentSnapshot<Map<String, dynamic>>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select a project'),
          content: SizedBox(
            width: 400,
            child: ListView(
              shrinkWrap: true,
              children: snapshot.docs.map((projectDocument) {
                final projectData = projectDocument.data();
                final projectName =
                    projectData['name'] as String? ?? 'Unnamed project';

                return ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(projectName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(dialogContext, projectDocument);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (!mounted || selectedProject == null) return;

    final projectData = selectedProject.data();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectFilesPage(
          projectId: selectedProject.id,
          projectName:
              projectData['name'] as String? ?? 'Project Files',
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not load projects: $e'),
      ),
    );
  }
}



 Future <void> logout() async{
      await FirebaseAuth.instance.signOut();
  }

 Future <void> logout() async{
      await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tlBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          return Row(
            children: [
              if (!isMobile) _buildSidebar(),
              Expanded(
                child: Column(
                  children: [
                    _buildHeader(isMobile),
                    Expanded(
                      child: TeamLeaderPageContent(
                        page: selectedPage,
                        onNavigate: navigateTo,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      drawer: null,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 258,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 25, 14, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [tlPurple, tlBlue],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                            Icons.code_rounded,
                            color: devText,
                            size: 25,
                          ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CodeAtlas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: tlText,
                      ),
                    ),
                    Text(
                      'TEAM WORKSPACE',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.2,
                        color: tlMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 12),
            child: Text(
              'TEAM LEADER MENU',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w700,
                color: tlMuted,
              ),
            ),
          ),
          _navItem(
            'Assign Task',
            Icons.add_task_rounded,
          ),
          const SizedBox(height: 5),
          _projectMenu(),
          const SizedBox(height: 5),
          _navItem('Schedule', Icons.calendar_month_rounded),
          _navItem('Team Leader', Icons.manage_accounts_rounded),
          _navItem('Progress', Icons.trending_up_rounded),
          _navItem('Team Members', Icons.groups_rounded),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [tlPink, tlLilac, tlBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 23),
                SizedBox(height: 9),
                Text(
                  'Keep your team moving!',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: tlText,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Assign tasks, track blockers and celebrate progress.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: tlText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFF0EFF5)),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),
            leading: const CircleAvatar(
              backgroundColor: tlLilac,
              child: Icon(Icons.person, color: tlText),
            ),
            title: const Text(
              'Team Leader',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: tlText,
              ),
            ),
            subtitle: const Text(
              'Project workspace',
              style: TextStyle(fontSize: 10, color: tlMuted),
            ),
            trailing: const Icon(
              Icons.more_horiz,
              color: tlMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _projectMenu() {
    final projectSelected = [
      'Summary',
      'Files',
      'Bugs',
    ].contains(selectedPage);

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              projectExpanded = !projectExpanded;
              if (!projectExpanded && projectSelected) {
                selectedPage = 'Summary';
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: projectSelected
                  ? const Color(0xFFF2EEFF)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_copy_rounded,
                  size: 20,
                  color: projectSelected ? tlText : tlMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'View Project',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: projectSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: tlText,
                    ),
                  ),
                ),
                Icon(
                  projectExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: tlMuted,
                  size: 19,
                ),
              ],
            ),
          ),
        ),
        if (projectExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 31, top: 3),
            child: Column(
              children: [
                _subNavItem('Summary', Icons.dashboard_outlined),
                _subNavItem('Files', Icons.folder_open_outlined),
                _subNavItem('Bugs', Icons.bug_report_outlined),
              ],
            ),
          ),
      ],
    );
  }

  Widget _subNavItem(String title, IconData icon) {
    final active = selectedPage == title;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => navigateTo(title),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        margin: const EdgeInsets.only(bottom: 3),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF6F2FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 17,
              color: active ? const Color(0xFF8068CE) : tlMuted,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: active ? tlText : tlMuted,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String title, IconData icon) {
    final active = selectedPage == title;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => navigateTo(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF2EEFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? const Color(0xFF8068CE) : tlMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: tlText,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (active)
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF8068CE),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      height: 88,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0EFF5)),
        ),
      ),
      child: Row(
        children: [
          if (isMobile)
            const Icon(Icons.menu_rounded, color: tlText),
          if (isMobile) const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedPage,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: tlText,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage projects, tasks and team performance',
                  style: TextStyle(fontSize: 11, color: tlMuted),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tlBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: tlText,
            ),
          ),
          const SizedBox(width: 13),
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
    );
  }
}
