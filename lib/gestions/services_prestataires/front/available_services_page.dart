import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/services_prestataires/back/offered_service.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/demander_devis_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/fiche_publique_page.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Catalogue en lecture seule pour un client : offres approuvées et tarifées.
class AvailableServicesPage extends StatelessWidget {
  /// Affiche les offres visibles de [etat].
  const AvailableServicesPage({super.key, required this.etat});

  /// Offres des prestataires.
  final ServicesPrestatairesEtat etat;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: etat,
      builder: (context, _) {
        final moi = utilisateursStore.current?.id;
        final services = [
          for (final service in etat.catalogue)
            if (service.prestataireId != moi) service,
        ];
        final miennes = [
          for (final service in etat.catalogue)
            if (service.prestataireId == moi) service,
        ];
        return Scaffold(
          appBar: AppBar(title: const Text('Services')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                'Services disponibles',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const Text('Choisissez un métier, puis demandez un devis.'),
              if (miennes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Votre offre', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final service in miennes)
                  Card(
                    child: ListTile(
                      leading: Icon(service.icon),
                      title: Text(service.title),
                      subtitle: Text('${service.city} · ${service.rate}'),
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              if (services.isEmpty) const Text('Aucun service publié pour le moment.'),
              for (final service in services) ...[
                _ServiceCard(service: service, etat: etat),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.etat});

  final OfferedService service;
  final ServicesPrestatairesEtat etat;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: IndigoOrChart.primaireConteneur,
                  foregroundColor: IndigoOrChart.primaire,
                  child: Icon(service.icon),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(service.providerName),
                      Text('${service.city} · ${service.rate}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => FichePubliquePage(
                            etat: etat,
                            prestataireId: service.prestataireId,
                          ),
                        ),
                      );
                    },
                    child: const Text('Voir la fiche'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => DemanderDevisPage(service: service),
                        ),
                      );
                    },
                    child: const Text('Demander un devis'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
