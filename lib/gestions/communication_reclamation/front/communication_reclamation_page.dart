import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_store.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/alertes_page.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/avis_page.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/messages_page.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/reclamations_page.dart';

/// Écran de la gestion, avec un onglet par responsabilité et selon le rôle.
class CommunicationReclamationPage extends StatelessWidget {
  /// Relie les onglets au back partagé.
  const CommunicationReclamationPage({super.key});

  /// Nom affiché dans le menu.
  static const title = 'Communication & réclamation';

  /// Responsabilités réservées à cette gestion.
  static const responsibilities = [
    'Chat',
    'Avis',
    'Réclamations',
    'Notifications',
  ];

  @override
  Widget build(BuildContext context) {
    final store = communicationStore;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final user = store.session;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Connectez-vous pour voir vos échanges.')),
          );
        }
        return _Onglets(
          key: ValueKey('${user.id}-${store.adminView}'),
          admin: store.adminView,
        );
      },
    );
  }
}

class _Onglets extends StatefulWidget {
  const _Onglets({super.key, required this.admin});

  final bool admin;

  @override
  State<_Onglets> createState() => _OngletsState();
}

class _OngletsState extends State<_Onglets> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = communicationStore;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.admin ? 'Supervision' : 'Vos échanges'),
        actions: [
          IconButton(
            tooltip: 'Réglages des notifications',
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ReglagesAlertesPage()),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'NEXUS',
                style: TextStyle(
                  color: IndigoOrChart.onPrimaire,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: [
            const Tab(text: 'Messages'),
            Tab(text: store.alertesNonLues == 0 ? 'Alertes' : 'Alertes (${store.alertesNonLues})'),
            const Tab(text: 'Avis'),
            const Tab(text: 'Réclamations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          MessagesPage(),
          AlertesPage(),
          AvisPage(),
          ReclamationsPage(),
        ],
      ),
    );
  }
}
