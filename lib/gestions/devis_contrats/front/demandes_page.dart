import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/demande_devis.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Demandes reçues par le prestataire connecté.
class DemandesPage extends StatelessWidget {
  /// Liste les demandes encore visibles.
  const DemandesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (!store.providerView) {
          return const AccesRefuse(
            title: 'Demandes',
            message: 'Ces demandes sont réservées à un prestataire.',
          );
        }
        final demandes = store.demandesRecues();
        return DevisContratsFrame(
          title: 'Demandes de devis',
          child: ListView(
            children: [
              if (demandes.isEmpty)
                const Text('Aucune demande reçue.')
              else
                for (final demande in demandes)
                  _DemandeCard(demandeId: demande.id),
            ],
          ),
        );
      },
    );
  }
}

class _DemandeCard extends StatelessWidget {
  const _DemandeCard({required this.demandeId});

  final String demandeId;

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);
    final demande = store.findDemande(demandeId);
    if (demande == null) return const SizedBox.shrink();
    final ouverte = demande.statut == StatutDemande.recue;
    final options = demande.options.map((option) => option.label).join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoLigne('Client', store.nomDe(demande.clientId)),
            InfoLigne('Service', demande.service),
            InfoLigne('Date', formatDate(demande.date)),
            InfoLigne('Lieu', demande.lieu),
            InfoLigne('Distance', formatKm(demande.distanceKm)),
            InfoLigne('Options demandées', options),
            StatutTexte(
              label: labelStatutDemande(demande.statut),
              color: Theme.of(context).colorScheme.secondary,
            ),
            if (ouverte) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => openDevisPage(
                        context,
                        DevisContratsRoutes.creer,
                        arguments: demande.id,
                      ),
                      child: const Text('Voir'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => store.refuserDemande(demande.id),
                      child: const Text('Refuser'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
