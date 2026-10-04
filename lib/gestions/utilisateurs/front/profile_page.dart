import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/utilisateurs/back/provider_profile.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_frame.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';

/// Profil du compte ouvert, et portes vers les autres écrans.
class ProfilePage extends StatelessWidget {
  /// Affiche l'identité et les liens du compte.
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final user = store.current;
        if (user == null) {
          return const _SignedOut();
        }

        return UtilisateursFrame(
          title: 'Profil',
          leaveGestion: true,
          child: ListView(
            children: [
              CircleAvatar(
                radius: 28,
                child: Text(user.firstName.isEmpty ? '?' : user.firstName[0]),
              ),
              const SizedBox(height: 12),
              Text(user.fullName, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(user.email),
              Text('${user.phone} · ${user.city}'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final role in user.roles) Chip(label: Text(labelForRole(role))),
                ],
              ),
              if (user.providerProfile != null) ...[
                const SizedBox(height: 16),
                _ProviderFacts(profile: user.providerProfile!),
              ],
              if (user.hasRole(UserRole.admin) && store.clientInterface) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: store.closeClientInterface,
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: const Text('Interface admin'),
                ),
              ],
              const SizedBox(height: 16),
              _Link(
                icon: Icons.edit_outlined,
                title: 'Modifier le profil',
                onTap: () => openUtilisateursPage(context, UtilisateursRoutes.edit),
              ),
              _Link(
                icon: Icons.lock_outline,
                title: 'Sécurité',
                onTap: () => openUtilisateursPage(context, UtilisateursRoutes.security),
              ),
              if (!user.isSimpleClient)
                _Link(
                  icon: Icons.badge_outlined,
                  title: 'Rôle',
                  onTap: () => openUtilisateursPage(context, UtilisateursRoutes.role),
                ),
              if (user.hasRole(UserRole.admin))
                _Link(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Gérer les utilisateurs',
                  onTap: () => openUtilisateursPage(context, UtilisateursRoutes.accounts),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: store.signOut,
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProviderFacts extends StatelessWidget {
  const _ProviderFacts({required this.profile});

  final ProviderProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile.service, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(profile.rateLabel),
            Text(profile.skills.join(' · ')),
            Text(profile.availability.join(', ')),
            if (profile.presentation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(profile.presentation),
            ],
          ],
        ),
      ),
    );
  }
}

class _SignedOut extends StatelessWidget {
  const _SignedOut();

  @override
  Widget build(BuildContext context) {
    return UtilisateursFrame(
      title: 'Profil',
      leaveGestion: true,
      child: ListView(
        children: [
          const Text('Aucun compte n\'est ouvert.'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => openUtilisateursRoot(context, UtilisateursRoutes.welcome),
            child: const Text('Retour à l\'entrée'),
          ),
        ],
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
