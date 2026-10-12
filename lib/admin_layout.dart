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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(36.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Initialize Project Metadata",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            const Text(
              "Provide project details and upload source documents (README, Architecture PDFs) for Supabase Storage & AI analysis.",
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 28),
            
            // Project Name Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Project Name',
                hintText: 'e.g., CodeAtlas / InitifyApp',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: const Color(0xFFbbd0ff).withOpacity(0.2),
                labelStyle: const TextStyle(color: Colors.black87),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: const Color(0xFFbbd0ff).withOpacity(0.2),
                labelStyle: const TextStyle(color: Colors.black87),
              ),
            ),
            const SizedBox(height: 24),

            // File Upload Section with Mixed Pastel Border
            const Text("Project Files / Documentation", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFffd6ff).withOpacity(0.3), const Color(0xFFc8b6ff).withOpacity(0.2)],
                ),
                border: Border.all(color: const Color(0xFFc8b6ff), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.cloud_upload_outlined, size: 36, color: Color(0xFFc8b6ff)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedFileName ?? "Drag & drop README, API docs, or PDFs here",
                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFb8c0ff),
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedFileName = "README_v2.md & architecture_spec.pdf selected";
                      });
                    },
                    child: const Text("Browse Supabase Buckets", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Gradient Submit Button
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFc8b6ff), Color(0xFFb8c0ff), Color(0xFFbbd0ff)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFc8b6ff).withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Project saved to Firestore & files uploaded to Supabase!")),
                  );
                },
                child: const Text("Generate AI Onboarding Experience", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
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
        const Text("Developer Onboarding Progress Metrics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildMetricCard("Active Onboardees", "12", Icons.group, const Color(0xFFffd6ff), const Color(0xFFe7c6ff))),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard("Avg Completion Time", "4.5 Days", Icons.timer, const Color(0xFFe7c6ff), const Color(0xFFc8b6ff))),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard("RAG Queries Solved", "342", Icons.psychology, const Color(0xFFb8c0ff), const Color(0xFFbbd0ff))),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color1, Color color2) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1.withOpacity(0.7), color2.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color2.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
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
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text("Teams Management View (Firestore Connected)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// 2c) Schedule Screen
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text("Day-wise Onboarding Schedule View", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}