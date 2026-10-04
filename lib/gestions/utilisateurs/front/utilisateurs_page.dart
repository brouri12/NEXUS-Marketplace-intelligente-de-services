import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/utilisateurs_store.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';

/// Gestion utilisateurs : navigateur interne et menu sur grand écran.
class UtilisateursPage extends StatefulWidget {
  /// Relie les écrans à [store].
  const UtilisateursPage({super.key, required this.store});

  /// Back des comptes, profils, rôles et de la sécurité.
  final UtilisateursStore store;

  /// Nom affiché dans le menu des gestions.
  static const title = 'Utilisateurs';

  /// Responsabilités de cette gestion.
  static const responsibilities = ['Comptes', 'Profils', 'Rôles', 'Sécurité'];

  @override
  State<UtilisateursPage> createState() => _UtilisateursPageState();
}

class _UtilisateursPageState extends State<UtilisateursPage> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        return Row(
          children: [
            if (wide)
              SizedBox(
                width: 260,
                child: ListenableBuilder(
                  listenable: widget.store,
                  builder: (context, _) => _CompteMenu(
                    store: widget.store,
                    onOpen: _open,
                  ),
                ),
              ),
            Expanded(
              child: Navigator(
                key: _navigatorKey,
                initialRoute: UtilisateursRoutes.welcome,
                onGenerateRoute: (settings) {
                  return UtilisateursRoutes.generate(settings, widget.store);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _open(String route) {
    _navigatorKey.currentState?.pushNamed(route);
  }
}

class _CompteMenu extends StatelessWidget {
  const _CompteMenu({required this.store, required this.onOpen});

  final UtilisateursStore store;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final user = store.current;
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        children: [
          Text('Utilisateurs', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (user == null) ...[
            _MenuButton(
              label: 'Entrée',
              onPressed: () => onOpen(UtilisateursRoutes.welcome),
            ),
            _MenuButton(
              label: 'Créer un compte',
              onPressed: () => onOpen(UtilisateursRoutes.signUp),
            ),
            _MenuButton(
              label: 'Se connecter',
              onPressed: () => onOpen(UtilisateursRoutes.signIn),
            ),
          ] else ...[
            Text(user.fullName),
            const SizedBox(height: 8),
            _MenuButton(
              label: 'Profil',
              onPressed: () => onOpen(UtilisateursRoutes.profile),
            ),
            _MenuButton(
              label: 'Modifier le profil',
              onPressed: () => onOpen(UtilisateursRoutes.edit),
            ),
            _MenuButton(
              label: 'Sécurité',
              onPressed: () => onOpen(UtilisateursRoutes.security),
            ),
            if (!user.isSimpleClient)
              _MenuButton(
                label: 'Rôle',
                onPressed: () => onOpen(UtilisateursRoutes.role),
              ),
            if (user.hasRole(UserRole.admin))
              _MenuButton(
                label: 'Gérer les utilisateurs',
                onPressed: () => onOpen(UtilisateursRoutes.accounts),
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
