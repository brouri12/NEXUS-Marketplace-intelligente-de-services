import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/services_prestataires/back/offered_service.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/provider_profile.dart';

/// Catalogue en lecture seule pour un client.
class AvailableServicesPage extends StatelessWidget {
  /// Affiche [services].
  const AvailableServicesPage({super.key, required this.services, this.ownOffer});

  /// Offres disponibles.
  final List<OfferedService> services;

  /// Fiche du prestataire connecté, s'il est aussi client.
  final ProviderProfile? ownOffer;

  @override
  Widget build(BuildContext context) {
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
          const Text('Choisissez un métier. Le détail et le devis viendront ensuite.'),
          if (ownOffer != null) ...[
            const SizedBox(height: 16),
            Text('Votre offre', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(OfferedService.iconFor(ownOffer!.service)),
                title: Text(ownOffer!.service),
                subtitle: Text(
                  '${ownOffer!.rateLabel}\n${ownOffer!.skills.join(' · ')}',
                ),
                isThreeLine: true,
              ),
            ),
          ],
          const SizedBox(height: 16),
          for (final service in services) ...[
            _ServiceCard(service: service),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final OfferedService service;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
      ),
    );
  }
}
