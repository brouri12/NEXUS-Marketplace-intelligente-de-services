import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/devis_contrats_store.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Gestion devis et contrats : navigateur interne et menu sur grand écran.
class DevisContratsPage extends StatefulWidget {
  /// Relie les écrans à [store].
  const DevisContratsPage({super.key, required this.store});

  /// Back des devis, contrats et modifications.
  final DevisContratsStore store;

  /// Nom affiché dans le menu des gestions.
  static const title = 'Devis et contrats';

  /// Responsabilités de cette gestion.
  static const responsibilities = [
    'Devis',
    'Contrats',
    'Signatures',
    'Modifications',
  ];

  @override
  State<DevisContratsPage> createState() => _DevisContratsPageState();
}

class _DevisContratsPageState extends State<DevisContratsPage> {
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
                  listenable: Listenable.merge([widget.store, utilisateursStore]),
                  builder: (context, _) => _DevisMenu(
                    store: widget.store,
                    onOpen: _open,
                  ),
                ),
              ),
            Expanded(
              child: Navigator(
                key: _navigatorKey,
                initialRoute: DevisContratsRoutes.accueil,
                onGenerateRoute: (settings) {
                  return DevisContratsRoutes.generate(settings, widget.store);
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

class _DevisMenu extends StatelessWidget {
  const _DevisMenu({required this.store, required this.onOpen});

  final DevisContratsStore store;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        children: [
          Text('Accès', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (store.providerView) ...[
            const _MenuLabel('Prestataire'),
            _MenuButton(
              label: 'Demandes',
              onPressed: () => onOpen(DevisContratsRoutes.demandes),
            ),
            _MenuButton(
              label: 'Mes devis',
              onPressed: () => onOpen(DevisContratsRoutes.devisPrestataire),
            ),
            _MenuButton(
              label: 'Mes contrats',
              onPressed: () => onOpen(DevisContratsRoutes.contratsPrestataire),
            ),
          ],
          if (store.clientView) ...[
            const _MenuLabel('Client'),
            _MenuButton(
              label: 'Mes devis',
              onPressed: () => onOpen(DevisContratsRoutes.devisClient),
            ),
            _MenuButton(
              label: 'Mes contrats',
              onPressed: () => onOpen(DevisContratsRoutes.contratsClient),
            ),
          ],
          if (store.adminView) ...[
            const _MenuLabel('Admin'),
            _MenuButton(
              label: 'Gestion des devis',
              onPressed: () => onOpen(DevisContratsRoutes.devisAdmin),
            ),
            _MenuButton(
              label: 'Gestion des contrats',
              onPressed: () => onOpen(DevisContratsRoutes.contratsAdmin),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(label),
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
