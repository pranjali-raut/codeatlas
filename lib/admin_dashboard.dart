
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

const Color lavender = Color(0xFFC8B6FF);
const Color palePink = Color(0xFFFFD6FF);
const Color lightPurple = Color(0xFFE7C6FF);
const Color periwinkle = Color(0xFFB8C0FF);
const Color lightBlue = Color(0xFFBBD0FF);
const Color ink = Color(0xFF28243D);
const Color muted = Color(0xFF858198);

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class Project {
  final String name;
  final String description;
  final List<String> files;
  final DateTime createdAt;

  Project({
    required this.name,
    required this.description,
    required this.files,
    required this.createdAt,
  });
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedPage = 0;
  final List<Project> projects = [];
  final List<String> menuItems = [
    'Overview',
    'Create Project',
    'Projects',
    'Progress',
    'Teams',
    'Schedule',
  ];

  final List<IconData> menuIcons = [
    Icons.grid_view_rounded,
    Icons.add_box_outlined,
    Icons.folder_open_rounded,
    Icons.trending_up_rounded,
    Icons.groups_2_outlined,
    Icons.calendar_month_rounded,
  ];

  void navigate(int index) {
    setState(() => selectedPage = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 850;

          return Row(
            children: [
              if (wide) _sidebar(),
              Expanded(
                child: Column(
                  children: [
                    _topBar(wide),
                    Expanded(
                      child: selectedPage == 1
                          ? _createProjectPage()
                          : _pageContent(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      drawer: MediaQuery.of(context).size.width < 850
          ? Drawer(child: _sidebar())
          : null,
    );
  }

  Widget _sidebar() {
    return Container(
      width: 245,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 16, 30),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [palePink, lavender, lightBlue],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: ink,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OnboardAI',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                      Text(
                        'ADMIN WORKSPACE',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 23, bottom: 12),
              child: Text(
                'WORKSPACE',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700,
                  color: muted,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final active = selectedPage == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Material(
                      color: active
                          ? const Color(0xFFF0E9FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: Icon(
                          menuIcons[index],
                          size: 21,
                          color: active ? const Color(0xFF7653B6) : muted,
                        ),
                        title: Text(
                          menuItems[index],
                          style: TextStyle(
                            color: active
                                ? const Color(0xFF62429B)
                                : const Color(0xFF5E5A70),
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        trailing: active
                            ? Container(
                                width: 5,
                                height: 23,
                                decoration: BoxDecoration(
                                  color: lavender,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              )
                            : null,
                        onTap: () {
                          navigate(index);
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFEEFF), Color(0xFFEDEAFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF7752B4)),
                  SizedBox(height: 9),
                  Text(
                    'AI-powered onboarding',
                    style: TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Turn project knowledge into a guided learning experience.',
                    style: TextStyle(
                      color: muted,
                      fontSize: 10,
                      height: 1.5,
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

  Widget _topBar(bool wide) {
    return Container(
      height: 78,
      padding: EdgeInsets.symmetric(horizontal: wide ? 30 : 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0EDF5)),
        ),
      ),
      child: Row(
        children: [
          if (!wide)
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
          Expanded(
            child: Text(
              selectedPage == 1
                  ? 'Create Project'
                  : menuItems[selectedPage],
              style: const TextStyle(
                color: ink,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          if (wide)
            Container(
              width: 235,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: muted, size: 20),
                  SizedBox(width: 9),
                  Text(
                    'Search workspace...',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: ink,
            ),
          ),
          const SizedBox(width: 5),
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [lightPurple, lightBlue],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.person_outline_rounded, color: ink),
          ),
        ],
      ),
    );
  }

  Widget _pageContent() {
    switch (selectedPage) {
      case 2:
        return _projectsPage();
      case 3:
        return _progressPage();
      case 4:
        return _teamsPage();
      case 5:
        return _schedulePage();
      default:
        return _overviewPage();
    }
  }

  Widget _overviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE6FF), Color(0xFFE7DFFF),
                  Color(0xFFDDE8FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(23),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 22,
              spacing: 20,
              children: [
                const SizedBox(
                  width: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR PROJECTS,\\nUNDERSTOOD.',
                        style: TextStyle(
                          color: ink,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Welcome to OnboardAI. Transform complex codebases '
                        'into clear, guided onboarding experiences.',
                        style: TextStyle(
                          color: Color(0xFF625A79),
                          fontSize: 13,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => navigate(1),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create project'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF55417D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 17,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 27),
          const Text(
            'Workspace overview',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth > 900
                  ? 4
                  : constraints.maxWidth > 550
                      ? 2
                      : 1;
              final width = (constraints.maxWidth - (count - 1) * 14) / count;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _statCard('Total projects', '${projects.length}',
                      Icons.folder_copy_outlined, palePink, width),
                  _statCard('Team members', '0',
                      Icons.groups_outlined, lightPurple, width),
                  _statCard('Tasks completed', '0',
                      Icons.task_alt_rounded, periwinkle, width),
                  _statCard('Onboarding rate', '0%',
                      Icons.insights_rounded, lightBlue, width),
                ],
              );
            },
          ),
          const SizedBox(height: 29),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent projects',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              TextButton(
                onPressed: () => navigate(2),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _projectList(),
          const SizedBox(height: 24),
          _infoBanner(),
        ],
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFF0EDF5)),
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
            child: Icon(icon, color: ink, size: 21),
          ),
          const SizedBox(height: 17),
          Text(
            value,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: muted)),
        ],
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF7254AE)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make onboarding effortless',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Create a project and add its README, API documentation, '
                  'and other project files to begin building your knowledge base.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _createProjectPage() {
    return _CreateProjectForm(
      onCreate: (name, description, files) {
        setState(() {
          projects.insert(
            0,
            Project(
              name: name,
              description: description,
              files: files,
              createdAt: DateTime.now(),
            ),
          );
          selectedPage = 2;
        });
      },
    );
  }

  Widget _projectsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            spacing: 12,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All projects',
                    style: TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Manage project documentation and onboarding.',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () => navigate(1),
                icon: const Icon(Icons.add),
                label: const Text('New project'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _projectList(),
        ],
      ),
    );
  }

  Widget _projectList() {
    if (projects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEDE9F4)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(19),
              decoration: const BoxDecoration(
                color: Color(0xFFF0E9FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 32,
                color: Color(0xFF7653B6),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Your workspace is ready',
              style: TextStyle(
                color: ink,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Create your first project to get started.',
              style: TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => navigate(1),
              icon: const Icon(Icons.add),
              label: const Text('Create your first project'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: projects.map((project) {
        return Container(
          margin: const EdgeInsets.only(bottom: 13),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFF0EDF5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E9FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.folder_copy_outlined,
                  color: Color(0xFF7653B6),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      project.description,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 8,
                      runSpacing: 5,
                      children: [
                        _tag('${project.files.length} files'),
                        _tag('New project'),
                      ],
                    ),
                    if (project.files.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ...project.files.take(3).map(
                        (file) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.description_outlined,
                                size: 14,
                                color: muted,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  file,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: muted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (project.files.length > 3)
                        Text(
                          '+${project.files.length - 3} more files',
                          style: const TextStyle(
                            color: muted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: muted, size: 15),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6A4A9D),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _progressPage() {
    return _sectionPage(
      Icons.insights_rounded,
      'Onboarding progress',
      'Monitor how quickly developers understand your projects.',
      [
        _detailTile(
          Icons.task_alt_rounded,
          'Completed activities',
          '0 activities completed',
          periwinkle,
        ),
        _detailTile(
          Icons.pending_actions_rounded,
          'Pending activities',
          'Tasks will appear when onboarding plans are assigned.',
          lightPurple,
        ),
        _detailTile(
          Icons.flag_outlined,
          'Project milestones',
          'Track learning goals and onboarding milestones.',
          lightBlue,
        ),
      ],
    );
  }

  Widget _teamsPage() {
    return _sectionPage(
      Icons.groups_rounded,
      'Team management',
      'Organize managers, developers, and onboarding responsibilities.',
      [
        _detailTile(
          Icons.admin_panel_settings_outlined,
          'Administrators',
          'Manage project settings and workspace access.',
          lightPurple,
        ),
        _detailTile(
          Icons.supervisor_account_outlined,
          'Project managers',
          'Assign projects, mentors, and learning activities.',
          periwinkle,
        ),
        _detailTile(
          Icons.code_rounded,
          'Developers',
          'Help new team members understand the codebase.',
          lightBlue,
        ),
      ],
    );
  }

  Widget _schedulePage() {
    return _sectionPage(
      Icons.calendar_month_rounded,
      'Onboarding schedule',
      'Plan learning activities, reviews, and project milestones.',
      [
        _detailTile(
          Icons.event_available_outlined,
          'Upcoming activities',
          'No scheduled activities yet.',
          palePink,
        ),
        _detailTile(
          Icons.school_outlined,
          'Learning milestones',
          'Plan day-wise learning goals for developers.',
          lightPurple,
        ),
        _detailTile(
          Icons.groups_outlined,
          'Mentor meetings',
          'Coordinate project walkthroughs and review sessions.',
          lightBlue,
        ),
      ],
    );
  }

  Widget _sectionPage(
    IconData icon,
    String title,
    String subtitle,
    List<Widget> tiles,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: muted, fontSize: 13)),
          const SizedBox(height: 24),
          ...tiles,
        ],
      ),
    );
  }

  Widget _detailTile(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0EDF5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ink, size: 23),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateProjectForm extends StatefulWidget {
  final void Function(
    String name,
    String description,
    List<String> files,
  ) onCreate;

  const _CreateProjectForm({required this.onCreate});

  @override
  State<_CreateProjectForm> createState() => _CreateProjectFormState();
}

class _CreateProjectFormState extends State<_CreateProjectForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<String> selectedFiles = [];
  bool _pickingFiles = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }


Future<void> pickFiles() async {
  try {
    final List<PlatformFile> result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'md', 'docx', 'json', 'yaml'],
    );

    if (result.isNotEmpty) {
      setState(() {
        selectedFiles = {
          ...selectedFiles,
          ...result.map((file) => file.name),
        }.toList();
      });
    }
  } catch (e) {
    debugPrint('Error picking files: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bring your project to OnboardAI',
                style: TextStyle(
                  color: ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add project details and documentation to start '
                'building a developer onboarding workspace.',
                style: TextStyle(color: muted, fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEDE9F4)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FormHeading(
                        number: '01',
                        title: 'Project information',
                        subtitle: 'Tell us what your team is building.',
                      ),
                      const SizedBox(height: 22),
                      const _FieldLabel('Project name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Employee Management System',
                          prefixIcon: Icon(Icons.folder_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Please enter a project name'
                                : null,
                      ),
                      const SizedBox(height: 19),
                      const _FieldLabel('Project description'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 4,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText:
                              'Describe the project, its purpose, modules, '
                              'technologies, and intended users...',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Please add a project description'
                                : null,
                      ),
                      const SizedBox(height: 28),
                      const Divider(color: Color(0xFFF0EDF5)),
                      const SizedBox(height: 22),
                      const _FormHeading(
                        number: '02',
                        title: 'Project documentation',
                        subtitle:
                            'Select a README, API documentation, or project files.',
                      ),
                      const SizedBox(height: 18),
                      InkWell(
                        onTap: _pickingFiles ? null : pickFiles,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 30,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF8FF),
                            border: Border.all(
                              color: lavender,
                              width: 1.4,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFECE4FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 28,
                                  color: Color(0xFF7653B6),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _pickingFiles
                                    ? 'Opening file picker...'
                                    : 'Click to browse project files',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 7),
                              const Text(
                                'PDF, TXT, MD, DOCX, JSON and YAML',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: muted,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Selected files will be attached to this project.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (selectedFiles.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        ...selectedFiles.map(
                          (file) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F5FC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.description_outlined,
                                  color: Color(0xFF7653B6),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    file,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: ink,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Remove file',
                                  onPressed: () => setState(
                                    () => selectedFiles.remove(file),
                                  ),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 27),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _formKey.currentState?.reset();
                                _nameController.clear();
                                _descriptionController.clear();
                                setState(() => selectedFiles.clear());
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 17,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Clear form'),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  widget.onCreate(
                                    _nameController.text.trim(),
                                    _descriptionController.text.trim(),
                                    List<String>.from(selectedFiles),
                                  );
                                }
                              },
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Create project'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF654A99),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 17,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _FormHeading extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const _FormHeading({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFECE4FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Color(0xFF7653B6),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: ink,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    );
  }
}
