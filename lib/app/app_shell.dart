import 'package:flutter/material.dart';

import 'package:flutter_android_app/app/nexus_bottom_bar.dart';
import 'package:flutter_android_app/app/nexus_sidebar.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/communication_reclamation_module.dart';
import 'package:flutter_android_app/gestions/devis_contrats/devis_contrats_module.dart';
import 'package:flutter_android_app/gestions/marketplace/marketplace_module.dart';
import 'package:flutter_android_app/gestions/services_prestataires/services_prestataires_module.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/utilisateurs_store.dart';
import 'package:flutter_android_app/gestions/utilisateurs/front/utilisateurs_routes.dart';

/// Espace connecté : barre latérale pour l'admin, barre du bas pour les autres.
class AppShell extends StatefulWidget {
  /// Affiche [store] dans la barre et le contenu.
  const AppShell({super.key, required this.store});

  /// Session ouverte.
  final UtilisateursStore store;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final String _initialRoute;
  late String _selected;

  @override
  void initState() {
    super.initState();
    _initialRoute = homeRouteFor(widget.store.current);
    _selected = _initialRoute;
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator(
      key: _navigatorKey,
      initialRoute: _initialRoute,
      observers: [_SelectionObserver(onChanged: _remember)],
      onGenerateRoute: _route,
    );

    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final user = widget.store.current;
        final showAdmin = (user?.hasRole(UserRole.admin) ?? false) &&
            !widget.store.clientInterface;
        if (showAdmin) {
          return _AdminFrame(
            store: widget.store,
            selected: _selected,
            onSelect: _open,
            content: navigator,
          );
        }

        final entries = user == null
            ? const <SideEntry>[]
            : widget.store.clientInterface
            ? clientInterfaceEntries
            : bottomEntriesFor(user);
        return ColoredBox(
          color: IndigoOrChart.fond,
          child: Column(
            children: [
              Expanded(child: navigator),
              NexusBottomBar(
                entries: entries,
                selectedIndex: bottomIndexFor(_selected, entries),
                onSelect: _open,
              ),
            ],
          ),
        );
      },
    );
  }

  void _open(String route) {
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(route, (route) => false);
  }

  void _remember(String? route) {
    if (route == null || route == _selected || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && route != _selected) {
        setState(() => _selected = route);
      }
    });
  }

  Route<void> _route(RouteSettings settings) {
    final page = switch (settings.name) {
      ShellRoutes.marketplace => marketplaceModule.front(context),
      ShellRoutes.services => servicesPrestatairesModule.front(context),
      ShellRoutes.devis => devisContratsModule.front(context),
      ShellRoutes.communication => communicationReclamationModule.front(context),
      _ => null,
    };
    if (page != null) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => page,
      );
    }
    return UtilisateursRoutes.generate(settings, widget.store);
  }
}

class _AdminFrame extends StatelessWidget {
  const _AdminFrame({
    required this.store,
    required this.selected,
    required this.onSelect,
    required this.content,
  });

  final UtilisateursStore store;
  final String selected;
  final ValueChanged<String> onSelect;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        return ColoredBox(
          color: IndigoOrChart.fond,
          child: Row(
            children: [
              SizedBox(
                width: compact ? 76 : 272,
                child: NexusSidebar(
                  store: store,
                  selected: selected,
                  compact: compact,
                  onSelect: onSelect,
                  onLogout: store.signOut,
                  onOpenClient: store.openClientInterface,
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}

class _SelectionObserver extends NavigatorObserver {
  _SelectionObserver({required this.onChanged});

  final ValueChanged<String?> onChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onChanged(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onChanged(previousRoute?.settings.name);
  }
}
