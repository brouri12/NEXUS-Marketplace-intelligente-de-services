import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_frame.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';

/// Mot de passe, code de connexion et sessions ouvertes.
class SecurityPage extends StatefulWidget {
  /// Affiche les réglages de sécurité du compte ouvert.
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  var _error = '';
  var _saved = '';

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  void _changePassword() {
    final error = StoreScope.of(context).changePassword(
      currentPassword: _current.text,
      password: _next.text,
    );
    setState(() {
      _error = error ?? '';
      _saved = error == null ? 'Mot de passe enregistré.' : '';
    });
    if (error == null) {
      _current.clear();
      _next.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final user = store.current;
        if (user == null) {
          return UtilisateursFrame(
            title: 'Sécurité',
            child: ListView(
              children: [
                const Text('Connectez-vous pour continuer.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => openUtilisateursRoot(context, UtilisateursRoutes.welcome),
                  child: const Text('Retour à l\'entrée'),
                ),
              ],
            ),
          );
        }

        final sessions = store.sessionsOfCurrent();
        final others = sessions.where((session) => !session.current).length;

        return UtilisateursFrame(
          title: 'Sécurité',
          child: ListView(
            children: [
              Text('Mot de passe', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _current,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _next,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
              ),
              const SizedBox(height: 12),
              FormErrorText(message: _error),
              if (_saved.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_saved),
                ),
              FilledButton(
                onPressed: _changePassword,
                child: const Text('Changer le mot de passe'),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Code à la connexion'),
                subtitle: const Text(
                  'Une fois actif, le code de démonstration est 0000.',
                ),
                value: user.requiresSignInCode,
                onChanged: store.setSignInCodeRequired,
              ),
              const SizedBox(height: 8),
              Text('Sessions', style: Theme.of(context).textTheme.titleMedium),
              for (final session in sessions)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(session.label),
                  subtitle: Text(session.current ? 'Session en cours' : 'Autre appareil'),
                ),
              OutlinedButton(
                onPressed: others == 0 ? null : store.disconnectOtherSessions,
                child: const Text('Déconnecter les autres sessions'),
              ),
            ],
          ),
        );
      },
    );
  }
}
