import 'package:flutter/material.dart';

import 'package:flutter_android_app/app/home_page.dart';
import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';

/// Application NEXUS.
class NexusApp extends StatelessWidget {
  /// Lance l'accueil des gestions.
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXUS',
      theme: IndigoOrChart.theme,
      home: const HomePage(),
    );
  }
}
