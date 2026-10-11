import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/core/ui/nexus_motion.dart';
import 'package:flutter_android_app/gestions/logistique/back/logistique_store.dart';
import 'package:flutter_android_app/gestions/logistique/back/trajet.dart';
import 'package:flutter_android_app/gestions/logistique/front/logistique_detail_page.dart';
import 'package:flutter_android_app/gestions/logistique/front/logistique_form_page.dart';

/// Suivi des trajets : ceux que l'on conduit, ceux que l'on attend, ou tous.
class LogistiquePage extends StatefulWidget {
  /// Affiche les trajets visibles dans [store].
  const LogistiquePage({super.key, required this.store});

  /// Trajets et droits du compte ouvert.
  final LogistiqueStore store;

  /// Nom affiché dans le menu.
  static const title = 'Logistique';

  /// Responsabilités réservées à cette gestion.
  static const responsibilities = [
    'Suivi en temps réel',
    'Calcul d\'itinéraire',
    'Alertes de retards',
  ];

  @override
  State<LogistiquePage> createState() => _LogistiquePageState();
}

class _LogistiquePageState extends State<LogistiquePage> {
  TrajetStatus? _filtre;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final tous = store.visibles();
        final trajets = [
          for (final trajet in tous)
            if (_filtre == null || trajet.status == _filtre) trajet,
        ];
        final retards = tous.where((trajet) => trajet.status == TrajetStatus.enRetard).length;
        return Scaffold(
          appBar: AppBar(title: const Text(LogistiquePage.title)),
          backgroundColor: IndigoOrChart.fond,
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                store.adminView
                    ? 'Tous les trajets de la plateforme.'
                    : store.providerView
                    ? 'Planifiez vos trajets vers vos clients et signalez les retards.'
                    : 'Suivez l\'arrivée de vos prestataires.',
                style: const TextStyle(color: IndigoOrChart.texteMuted),
              ),
              if (retards > 0) ...[
                const SizedBox(height: 12),
                _AlerteRetard(nombre: retards),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Tous'),
                    selected: _filtre == null,
                    onSelected: (_) => setState(() => _filtre = null),
                  ),
                  for (final statut in TrajetStatus.values)
                    ChoiceChip(
                      label: Text(labelTrajetStatus(statut)),
                      selected: _filtre == statut,
                      onSelected: (_) => setState(() => _filtre = statut),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (trajets.isEmpty)
                const Text(
                  'Aucun trajet pour le moment.',
                  style: TextStyle(color: IndigoOrChart.texteMuted),
                ),
              for (var i = 0; i < trajets.length; i++)
                Apparition(
                  key: ValueKey(trajets[i].id),
                  index: i,
                  child: TrajetCard(store: store, trajet: trajets[i]),
                ),
            ],
          ),
          floatingActionButton: store.providerView
              ? FloatingActionButton.extended(
                  backgroundColor: IndigoOrChart.or,
                  foregroundColor: IndigoOrChart.onOr,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => LogistiqueFormPage(store: store),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nouveau trajet'),
                )
              : null,
        );
      },
    );
  }
}

class _AlerteRetard extends StatelessWidget {
  const _AlerteRetard({required this.nombre});

  final int nombre;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: IndigoOrChart.erreurConteneur,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IndigoOrChart.erreur),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: IndigoOrChart.erreur),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              nombre == 1 ? '1 trajet est en retard.' : '$nombre trajets sont en retard.',
              style: const TextStyle(
                color: IndigoOrChart.onErreurConteneur,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Couleur sémantique de [statut].
Color couleurTrajet(TrajetStatus statut) {
  return switch (statut) {
    TrajetStatus.enAttente => IndigoOrChart.attente,
    TrajetStatus.enCours => IndigoOrChart.succes,
    TrajetStatus.enRetard => IndigoOrChart.erreur,
    TrajetStatus.termine => IndigoOrChart.secondaire,
  };
}

/// Heure lisible, par exemple 14:30.
String formatHeure(DateTime value) {
  final h = value.hour.toString().padLeft(2, '0');
  final m = value.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// Carte d'un trajet dans la liste.
class TrajetCard extends StatelessWidget {
  /// Affiche [trajet].
  const TrajetCard({super.key, required this.store, required this.trajet});

  /// Trajets du compte ouvert.
  final LogistiqueStore store;

  /// Trajet affiché.
  final Trajet trajet;

  @override
  Widget build(BuildContext context) {
    final statusColor = couleurTrajet(trajet.status);
    final autre = store.adminView
        ? '${store.nomDe(trajet.prestataireId)} → ${store.nomDe(trajet.clientId)}'
        : trajet.prestataireId == store.session?.id
        ? 'Client : ${store.nomDe(trajet.clientId)}'
        : 'Prestataire : ${store.nomDe(trajet.prestataireId)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => LogistiqueDetailPage(store: store, trajetId: trajet.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trajet.numero,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: IndigoOrChart.primaire,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      labelTrajetStatus(trajet.status),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: IndigoOrChart.secondaire, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      trajet.pointDepart,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: IndigoOrChart.texte),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, color: IndigoOrChart.contour, size: 16),
                  ),
                  const Icon(Icons.flag_outlined, color: IndigoOrChart.or, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      trajet.destination,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: IndigoOrChart.texte),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.person_outline, color: IndigoOrChart.secondaire, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      autre,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: IndigoOrChart.texteMuted),
                    ),
                  ),
                  const Icon(Icons.access_time, color: IndigoOrChart.primaire, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'ETA ${formatHeure(trajet.eta)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: IndigoOrChart.primaire,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
