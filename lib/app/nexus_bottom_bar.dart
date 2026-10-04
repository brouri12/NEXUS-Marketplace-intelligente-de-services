import 'package:flutter/material.dart';

import 'package:flutter_android_app/app/nexus_sidebar.dart';
import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';

/// Barre du client, aussi quand un admin ouvre cette interface.
const clientInterfaceEntries = [
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
  SideEntry(
    route: UtilisateursRoutes.profile,
    label: 'Profil',
    icon: Icons.person_outline,
  ),
];

/// Icônes de la barre du bas selon le rôle ouvert.
List<SideEntry> bottomEntriesFor(UserAccount user) {
  return [
    if (user.hasRole(UserRole.client))
      const SideEntry(
        route: ShellRoutes.marketplace,
        label: 'Marketplace',
        icon: Icons.storefront_outlined,
      ),
    if (user.hasRole(UserRole.client) || user.hasRole(UserRole.provider))
      const SideEntry(
        route: ShellRoutes.services,
        label: 'Services',
        icon: Icons.handyman_outlined,
      ),
    const SideEntry(
      route: ShellRoutes.devis,
      label: 'Devis',
      icon: Icons.request_quote_outlined,
    ),
    const SideEntry(
      route: ShellRoutes.communication,
      label: 'Messages',
      icon: Icons.forum_outlined,
    ),
    const SideEntry(
      route: UtilisateursRoutes.profile,
      label: 'Profil',
      icon: Icons.person_outline,
    ),
  ];
}

/// Première page après la connexion, hors admin.
String homeRouteFor(UserAccount? user) {
  if (user == null || user.hasRole(UserRole.admin)) {
    return UtilisateursRoutes.profile;
  }
  if (user.hasRole(UserRole.client)) return ShellRoutes.marketplace;
  if (user.hasRole(UserRole.provider)) return ShellRoutes.services;
  return UtilisateursRoutes.profile;
}

/// Index de la barre qui correspond à [route].
int bottomIndexFor(String route, List<SideEntry> entries) {
  final direct = entries.indexWhere((entry) => entry.route == route);
  if (direct >= 0) return direct;
  final profile = entries.indexWhere(
    (entry) => entry.route == UtilisateursRoutes.profile,
  );
  if (profile >= 0 && _isAccountRoute(route)) return profile;
  return 0;
}

bool _isAccountRoute(String route) {
  return route == UtilisateursRoutes.profile ||
      route == UtilisateursRoutes.edit ||
      route == UtilisateursRoutes.security ||
      route == UtilisateursRoutes.role ||
      route == UtilisateursRoutes.accounts ||
      route == UtilisateursRoutes.account;
}

/// Barre du bas, indigo discret et pastille or sur l'icône choisie.
class NexusBottomBar extends StatelessWidget {
  /// Affiche [entries] et signale le choix par [onSelect].
  const NexusBottomBar({
    super.key,
    required this.entries,
    required this.selectedIndex,
    required this.onSelect,
  });

  /// Destinations visibles pour le rôle ouvert.
  final List<SideEntry> entries;

  /// Destination actuellement ouverte.
  final int selectedIndex;

  /// Ouvre la route de l'entrée choisie.
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Material(
      color: IndigoOrChart.surfaceHaute,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: IndigoOrChart.contourDiscret)),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: selectedIndex.clamp(0, entries.length - 1),
            onDestinationSelected: (index) => onSelect(entries[index].route),
            backgroundColor: IndigoOrChart.surfaceHaute,
            surfaceTintColor: const Color(0x00000000),
            indicatorColor: IndigoOrChart.orConteneur,
            height: 68,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 12,
                color: selected ? IndigoOrChart.orTexte : IndigoOrChart.texteMuted,
              );
            }),
            destinations: [
              for (final entry in entries)
                NavigationDestination(
                  icon: Icon(entry.icon, color: IndigoOrChart.texteMuted),
                  selectedIcon: Icon(
                    _selectedIcon(entry.icon),
                    color: IndigoOrChart.orTexte,
                  ),
                  label: entry.label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _selectedIcon(IconData icon) {
  return switch (icon) {
    Icons.storefront_outlined => Icons.storefront,
    Icons.handyman_outlined => Icons.handyman,
    Icons.request_quote_outlined => Icons.request_quote,
    Icons.forum_outlined => Icons.forum,
    Icons.person_outline => Icons.person,
    _ => icon,
  };
}
