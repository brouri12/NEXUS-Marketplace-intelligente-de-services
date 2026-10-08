import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_reclamation_api.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/communication_reclamation_screens.dart';

/// Écran réservé de la gestion communication et réclamation.
class CommunicationReclamationPage extends StatefulWidget {
  /// Relie cet écran à [back].
  const CommunicationReclamationPage({super.key, required this.back});

  /// Contrat back du chat, des avis, des réclamations et des notifications.
  final CommunicationReclamationApi back;

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
  State<CommunicationReclamationPage> createState() =>
      _CommunicationReclamationPageState();
}

class _CommunicationReclamationPageState
    extends State<CommunicationReclamationPage> {
  int _index = 0;
  static const _tabs = [
    (label: 'Messages', icon: Icons.forum_outlined),
    (label: 'Alertes', icon: Icons.notifications_none),
    (label: 'Avis', icon: Icons.star_outline),
    (label: 'Réclamations', icon: Icons.report_gmailerrorred_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabs[_index].label),
        actions: [
          if (_index == 1)
            IconButton(
              tooltip: 'Réglages des notifications',
              icon: const Icon(Icons.tune),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationSettingsPage(),
                ),
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
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          MessagesPage(),
          NotificationsPage(),
          ReviewsPage(),
          ComplaintsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }
}
