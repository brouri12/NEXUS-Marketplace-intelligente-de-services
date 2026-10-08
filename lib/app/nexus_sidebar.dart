import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/utilisateurs_store.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';

/// Entrée de la barre latérale.
class SideEntry {
  /// Crée une entrée avec son icône.
  const SideEntry({
    required this.route,
    required this.label,
    required this.icon,
    this.adminOnly = false,
  });

  /// Route ouverte dans la zone de contenu.
  final String route;

  /// Libellé affiché à côté de l'icône.
  final String label;

  /// Icône de l'entrée.
  final IconData icon;

  /// Whether only an admin sees this entry.
  final bool adminOnly;
}

/// Entrées du compte, sous la marque.
const accountEntries = [
  SideEntry(
    route: UtilisateursRoutes.profile,
    label: 'Profil',
    icon: Icons.person_outline,
  ),
  SideEntry(
    route: UtilisateursRoutes.edit,
    label: 'Modifier',
    icon: Icons.edit_outlined,
  ),
  SideEntry(
    route: UtilisateursRoutes.security,
    label: 'Sécurité',
    icon: Icons.lock_outline,
  ),
  SideEntry(
    route: UtilisateursRoutes.role,
    label: 'Rôle',
    icon: Icons.badge_outlined,
  ),
];

/// Action réservée à l'admin.
const adminEntries = [
  SideEntry(
    route: UtilisateursRoutes.accounts,
    label: 'Utilisateurs',
    icon: Icons.manage_accounts_outlined,
    adminOnly: true,
  ),
];

/// Entrées des autres gestions.
const gestionEntries = [
  SideEntry(
    route: ShellRoutes.marketplace,
    label: 'Marketplace',
    icon: Icons.storefront_outlined,
  ),
  SideEntry(
    route: ShellRoutes.services,
    label: 'Services',
    icon: Icons.handyman_outlined,
  ),
  SideEntry(
    route: ShellRoutes.devis,
    label: 'Devis',
    icon: Icons.request_quote_outlined,
  ),
  SideEntry(
    route: ShellRoutes.communication,
    label: 'Messages',
    icon: Icons.forum_outlined,
  ),
];

/// Noms de routes des gestions affichées dans le shell.
abstract final class ShellRoutes {
  /// Recherche et mise en relation.
  static const marketplace = '/shell/marketplace';

  /// Services et prestataires.
  static const services = '/shell/services';

  /// Devis et contrats.
  static const devis = '/shell/devis';

  /// Communication et réclamation.
  static const communication = '/shell/communication';
}

/// Barre latérale indigo, icônes seules sur un écran étroit.
class NexusSidebar extends StatelessWidget {
  /// Affiche la marque, le compte ouvert et les entrées.
  const NexusSidebar({
    super.key,
    required this.store,
    required this.selected,
    required this.compact,
    required this.onSelect,
    required this.onLogout,
    required this.onOpenClient,
  });

  /// Session utilisée pour le nom et le rôle admin.
  final UtilisateursStore store;

  /// Route actuellement visible.
  final String selected;

  /// Whether labels are hidden and only icons remain.
  final bool compact;

  /// Ouvre [route] dans le contenu.
  final ValueChanged<String> onSelect;

  /// Ferme la session.
  final VoidCallback onLogout;

  /// Affiche l'interface client.
  final VoidCallback onOpenClient;

  @override
  Widget build(BuildContext context) {
    final user = store.current;

    return ColoredBox(
      color: IndigoOrChart.primaire,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Brand(compact: compact),
              const SizedBox(height: 20),
              if (user != null) ...[
                _UserBlock(user: user, compact: compact),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _AccountMenu(
                      selected: selected,
                      compact: compact,
                      onSelect: onSelect,
                    ),
                    const SizedBox(height: 12),
                    _SectionLabel(label: 'Gestions', compact: compact),
                    if (user?.hasRole(UserRole.admin) ?? false)
                      for (final entry in adminEntries)
                        _SideButton(
                          entry: entry,
                          selected: selected == entry.route,
                          compact: compact,
                          onPressed: () => onSelect(entry.route),
                        ),
                    for (final entry in gestionEntries)
                      _SideButton(
                        entry: entry,
                        selected: selected == entry.route,
                        compact: compact,
                        onPressed: () => onSelect(entry.route),
                      ),
                  ],
                ),
              ),
              _SideButton(
                entry: const SideEntry(
                  route: '',
                  label: 'Interface client',
                  icon: Icons.phone_android_outlined,
                ),
                selected: false,
                compact: compact,
                onPressed: () {
                  onOpenClient();
                  onSelect(ShellRoutes.marketplace);
                },
              ),
              _SideButton(
                entry: const SideEntry(
                  route: '',
                  label: 'Déconnexion',
                  icon: Icons.logout,
                ),
                selected: false,
                compact: compact,
                onPressed: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  const _AccountMenu({
    required this.selected,
    required this.compact,
    required this.onSelect,
  });

  final String selected;
  final bool compact;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final open = accountEntries.any((entry) => entry.route == selected);
    final color = open ? IndigoOrChart.onOr : IndigoOrChart.onPrimaire;
    final background = open ? IndigoOrChart.or : const Color(0x00000000);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: PopupMenuButton<String>(
          tooltip: 'Compte',
          color: IndigoOrChart.surfaceHaute,
          onSelected: onSelect,
          itemBuilder: (context) {
            return [
              for (final entry in accountEntries)
                PopupMenuItem<String>(
                  value: entry.route,
                  child: Row(
                    children: [
                      Icon(
                        entry.icon,
                        color: selected == entry.route
                            ? IndigoOrChart.orTexte
                            : IndigoOrChart.secondaire,
                      ),
                      const SizedBox(width: 12),
                      Text(entry.label),
                    ],
                  ),
                ),
            ];
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 0 : 12,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: compact
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, color: color, size: 22),
                Icon(Icons.arrow_drop_down, color: color, size: 20),
                if (!compact) ...[
                  const SizedBox(width: 4),
                  Text('Compte', style: TextStyle(color: color)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.apartment_outlined, color: IndigoOrChart.or),
        if (!compact) ...[
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'NEXUS',
              style: TextStyle(
                color: IndigoOrChart.onPrimaire,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _UserBlock extends StatelessWidget {
  const _UserBlock({required this.user, required this.compact});

  final UserAccount user;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final initial = user.firstName.isEmpty ? '?' : user.firstName[0];
    if (compact) {
      return CircleAvatar(
        backgroundColor: IndigoOrChart.or,
        foregroundColor: IndigoOrChart.onOr,
        child: Text(initial),
      );
    }

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: IndigoOrChart.or,
          foregroundColor: IndigoOrChart.onOr,
          child: Text(initial),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: const TextStyle(color: IndigoOrChart.onPrimaire),
              ),
              Text(
                user.roles.map(labelForRole).join(' · '),
                style: const TextStyle(color: IndigoOrChart.primaireConteneur),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.compact});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Text(
        label,
        style: const TextStyle(color: IndigoOrChart.primaireConteneur),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.entry,
    required this.selected,
    required this.compact,
    required this.onPressed,
  });

  final SideEntry entry;
  final bool selected;
  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = selected ? IndigoOrChart.onOr : IndigoOrChart.onPrimaire;
    final background = selected ? IndigoOrChart.or : const Color(0x00000000);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Tooltip(
            message: entry.label,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 0 : 12,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: compact
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(entry.icon, color: color, size: 22),
                  if (!compact) ...[
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(entry.label, style: TextStyle(color: color)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
