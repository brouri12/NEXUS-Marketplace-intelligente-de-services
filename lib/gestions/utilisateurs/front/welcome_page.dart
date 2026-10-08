import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_frame.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';

/// Entrée de la gestion : créer un compte ou se connecter.
class WelcomePage extends StatelessWidget {
  /// Affiche les deux portes d'entrée.
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return UtilisateursFrame(
      title: 'Utilisateurs',
      leaveGestion: true,
      child: ListView(
        children: [
          Text('Comptes, profils, rôles, sécurité', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'NEXUS part d\'une phrase. Le compte garde le lieu, le téléphone et le rôle utilisés ensuite.',
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => openUtilisateursPage(context, UtilisateursRoutes.signUp),
            child: const Text('Créer un compte'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => openUtilisateursPage(context, UtilisateursRoutes.signIn),
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }
}
