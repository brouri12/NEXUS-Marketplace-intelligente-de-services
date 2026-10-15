import 'package:flutter/material.dart';

/// Écran réservé d'une gestion, en attendant son interface métier.
class GestionFrontPage extends StatelessWidget {
  /// Affiche le titre, les responsabilités et le back déjà relié.
  const GestionFrontPage({
    super.key,
    required this.title,
    required this.responsibilities,
    required this.back,
  });

  /// Nom de la gestion.
  final String title;

  /// Responsabilités affichées comme place réservée.
  final List<String> responsibilities;

  /// Contrat back branché sur cet écran.
  final Object back;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Partie front', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Interface réservée. Les écrans de cette gestion viendront ici.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text('Responsabilités', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final responsibility in responsibilities)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.circle_outlined, size: 12),
              title: Text(responsibility),
            ),
          const SizedBox(height: 16),
          Text('Partie back', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Contrat relié : ${back.runtimeType}',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
