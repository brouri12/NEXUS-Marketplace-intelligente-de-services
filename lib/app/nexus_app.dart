import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/communication_reclamation_module.dart';

/// Application NEXUS.
class NexusApp extends StatelessWidget {
  /// Lance l'accueil des gestions.
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXUS',
      theme: IndigoOrChart.theme,
      home: Builder(builder: communicationReclamationModule.front),
    );
  }
}
