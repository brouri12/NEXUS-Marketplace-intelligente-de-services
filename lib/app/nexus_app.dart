import 'package:flutter/material.dart';

import 'package:flutter_android_app/app/home_page.dart';

/// Application NEXUS.
class NexusApp extends StatelessWidget {
  /// Lance l'accueil des gestions.
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXUS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F3D4C)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
