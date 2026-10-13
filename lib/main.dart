
import 'package:codeatlas/authwrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
  url: 'https://kyxuhicwvdhtgppmyesq.supabase.co',
  publishableKey: 'sb_publishable_MTewaQkUrjAxKZmWjsKDfg_BOP34bnb',
  accessToken: () async {
    return FirebaseAuth.instance.currentUser?.getIdToken();
  },
);

  runApp(const CodeAtlasApp());
}

class CodeAtlasApp extends StatelessWidget {
  const CodeAtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeAtlas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB8C0FF),
          brightness: Brightness.light,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
