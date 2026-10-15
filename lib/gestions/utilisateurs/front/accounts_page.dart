import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_frame.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';

/// Liste des comptes, ouverte seulement pour un admin.
class AccountsPage extends StatelessWidget {
  /// Affiche chaque compte et mène à son détail.
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final user = store.current;
        if (user == null || !user.hasRole(UserRole.admin)) {
          return UtilisateursFrame(
            title: 'Comptes',
            child: ListView(
              children: const [
                Text('Cette liste est réservée à un compte admin.'),
              ],
            ),
          );
        }

        final accounts = store.accounts;
        return UtilisateursFrame(
          title: 'Utilisateurs',
          child: ListView.builder(
            itemCount: accounts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    '${accounts.length} comptes. Le crayon modifie l\'identité. La ligne ouvre les rôles et la suspension.',
                  ),
                );
              }
              final account = accounts[index - 1];
              final roles = account.roles.map(labelForRole).join(', ');
              final service = account.providerProfile?.service;
              final details = [
                account.email,
                roles,
                ?service,
                if (account.suspended) 'Suspendu',
                if (!account.confirmed) 'En attente',
              ].join(' · ');
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.manage_accounts_outlined),
                  title: Text(account.fullName),
                  subtitle: Text(details),
                  trailing: IconButton(
                    tooltip: 'Modifier ${account.fullName}',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => openUtilisateursPage(
                      context,
                      UtilisateursRoutes.edit,
                      arguments: account.id,
                    ),
                  ),
                  onTap: () => openUtilisateursPage(
                    context,
                    UtilisateursRoutes.account,
                    arguments: account.id,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
