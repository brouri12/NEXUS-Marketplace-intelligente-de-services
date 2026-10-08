import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_frame.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';

/// Détail admin d'un compte : rôles, suspension, dernier accès.
class AccountDetailPage extends StatefulWidget {
  /// Affiche le compte [userId].
  const AccountDetailPage({super.key, required this.userId});

  /// Identifiant reçu par la route.
  final String userId;

  @override
  State<AccountDetailPage> createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  final _reason = TextEditingController();
  var _error = '';

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final actor = store.current;
        final account = store.find(widget.userId);
        if (actor == null || !actor.hasRole(UserRole.admin) || account == null) {
          return UtilisateursFrame(
            title: 'Compte',
            child: ListView(
              children: const [Text('Ce compte n\'est pas accessible.')],
            ),
          );
        }

        final self = actor.id == account.id;
        final access = account.lastAccess;

        return UtilisateursFrame(
          title: account.fullName,
          child: ListView(
            children: [
              Text(account.email),
              Text('${account.phone} · ${account.city}'),
              if (account.providerProfile != null) ...[
                const SizedBox(height: 8),
                Text(account.providerProfile!.service),
                Text(account.providerProfile!.rateLabel),
                Text(account.providerProfile!.skills.join(' · ')),
              ],
              const SizedBox(height: 8),
              Text(
                access == null
                    ? 'Jamais connecté'
                    : 'Dernier accès : ${_format(access)}',
              ),
              if (account.suspended) ...[
                const SizedBox(height: 8),
                Text('Suspendu : ${account.suspensionReason}'),
              ],
              if (!account.confirmed) ...[
                const SizedBox(height: 8),
                const Text('En attente de confirmation'),
              ],
              const SizedBox(height: 16),
          if (!account.confirmed)
            FilledButton.icon(
              onPressed: () {
                final error = store.confirmProvider(account.id);
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                }
              },
              icon: const Icon(Icons.verified_outlined),
              label: const Text('Confirmer le compte'),
            ),
          if (!account.confirmed) const SizedBox(height: 12),
          FilledButton.icon(
                onPressed: () => openUtilisateursPage(
                  context,
                  UtilisateursRoutes.edit,
                  arguments: account.id,
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Modifier le compte'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Client'),
                subtitle: Text(
                  account.hasRole(UserRole.provider)
                      ? 'Inclus avec le rôle prestataire.'
                      : 'Décrire un besoin et demander un devis.',
                ),
                value: account.hasRole(UserRole.client) || account.hasRole(UserRole.provider),
                onChanged: account.hasRole(UserRole.provider)
                    ? null
                    : (value) => _roles(context, client: value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Prestataire'),
                value: account.hasRole(UserRole.provider),
                onChanged: (value) => _roles(context, provider: value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Admin'),
                value: account.hasRole(UserRole.admin),
                onChanged: self ? null : (value) => _roles(context, admin: value),
              ),
              const SizedBox(height: 8),
              FormErrorText(message: _error),
              if (account.suspended)
                FilledButton(
                  onPressed: () {
                    final error = store.restore(account.id);
                    setState(() => _error = error ?? '');
                  },
                  child: const Text('Rétablir'),
                )
              else ...[
                TextField(
                  controller: _reason,
                  decoration: const InputDecoration(labelText: 'Motif de suspension'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: self
                      ? null
                      : () {
                          final error = store.suspend(account.id, _reason.text);
                          setState(() => _error = error ?? '');
                        },
                  child: const Text('Suspendre'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _roles(
    BuildContext context, {
    bool? client,
    bool? provider,
    bool? admin,
  }) {
    final store = StoreScope.of(context);
    final account = store.find(widget.userId);
    if (account == null) return;
    final error = store.updateRoles(
      id: account.id,
      client: client ?? account.hasRole(UserRole.client),
      provider: provider ?? account.hasRole(UserRole.provider),
      admin: admin ?? account.hasRole(UserRole.admin),
    );
    setState(() => _error = error ?? '');
  }

  String _format(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }
}
