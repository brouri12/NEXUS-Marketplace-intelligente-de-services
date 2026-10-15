import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/gestions.dart';

/// Accueil qui ouvre chaque gestion.
class HomePage extends StatelessWidget {
  /// Affiche les cinq gestions reliées.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('NEXUS')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'Marketplace intelligente de services',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Chaque gestion a sa partie front et sa partie back. '
            'Les interfaces métier viendront dans ces emplacements.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final module in gestions)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(module.icon),
                title: Text(module.title),
                subtitle: Text(module.responsibilities.join(' · ')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: module.front),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
