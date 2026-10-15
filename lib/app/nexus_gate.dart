import 'package:flutter/material.dart';

import 'package:flutter_android_app/app/app_shell.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Choisit la connexion ou l'espace selon le rôle ouvert.
class NexusGate extends StatelessWidget {
  /// Écoute la session et affiche l'écran qui correspond.
  const NexusGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: utilisateursStore,
      builder: (context, _) {
        if (utilisateursStore.current == null) {
          return const _AuthHost(key: ValueKey('auth'));
        }
        return AppShell(key: const ValueKey('shell'), store: utilisateursStore);
      },
    );
  }
}

class _AuthHost extends StatefulWidget {
  const _AuthHost({super.key});

  @override
  State<_AuthHost> createState() => _AuthHostState();
}

class _AuthHostState extends State<_AuthHost> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      initialRoute: UtilisateursRoutes.signIn,
      onGenerateRoute: (settings) {
        return UtilisateursRoutes.generate(settings, utilisateursStore);
      },
    );
  }
}
