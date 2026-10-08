import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_frame.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';

/// Choix client et prestataire pour le compte ouvert.
class RolePage extends StatelessWidget {
  /// Affiche les rôles que la personne peut activer elle-même.
  const RolePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final user = store.current;
        if (user == null) {
          return UtilisateursFrame(
            title: 'Rôle',
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

        if (user.isSimpleClient) {
          return UtilisateursFrame(
            title: 'Rôle',
            child: ListView(
              children: const [
                Text(
                  'Un client ne peut pas changer son rôle. Seul un administrateur peut le modifier.',
                ),
              ],
            ),
          );
        }

        return UtilisateursFrame(
          title: 'Rôle',
          child: ListView(
            children: [
              const Text(
                'Un prestataire reste aussi client : il peut décrire un besoin. Le rôle prestataire ne se retire pas tant qu\'un contrat est en cours.',
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Client'),
                subtitle: Text(
                  user.hasRole(UserRole.provider)
                      ? 'Inclus avec le rôle prestataire.'
                      : 'Décrire un besoin et demander un devis.',
                ),
                value: user.hasRole(UserRole.client) || user.hasRole(UserRole.provider),
                onChanged: user.hasRole(UserRole.provider)
                    ? null
                    : (value) {
                        final error = store.updateOwnRoles(
                          client: value,
                          provider: user.hasRole(UserRole.provider),
                        );
                        _show(context, error);
                      },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Prestataire'),
                subtitle: Text(
                  user.hasActiveContract
                      ? 'Un contrat est en cours.'
                      : 'Aucun contrat en cours.',
                ),
                value: user.hasRole(UserRole.provider),
                onChanged: (value) {
                  final error = store.updateOwnRoles(
                    client: user.hasRole(UserRole.client),
                    provider: value,
                  );
                  _show(context, error);
                },
              ),
              if (user.hasRole(UserRole.admin))
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Admin'),
                  subtitle: Text('Ce rôle se change depuis la liste des comptes.'),
                ),
            ],
          ),
        );
      },
    );
  }

  void _show(BuildContext context, String? error) {
    if (error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
}
