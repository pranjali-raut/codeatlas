import 'package:flutter/material.dart';

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
    return const Center(
      child: Text("Teams Management View (Firestore Connected)", style: TextStyle(fontSize: 16)),
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