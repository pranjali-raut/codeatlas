
import 'package:flutter/material.dart';
import 'developer_dashboard.dart';
import 'developer_theme.dart';

void main() {
  runApp(const CodeAtlasApp());
}

class CodeAtlasApp extends StatelessWidget {
  const CodeAtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CodeAtlas Developer',
      theme: developerTheme(),
      home: const DeveloperDashboard(),
    );
  }
}
