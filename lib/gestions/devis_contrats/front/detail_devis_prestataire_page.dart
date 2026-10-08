import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/devis.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Détail d'un devis pour le prestataire qui l'a préparé.
class DetailDevisPrestatairePage extends StatelessWidget {
  /// Affiche le devis [devisId].
  const DetailDevisPrestatairePage({super.key, required this.devisId});

  /// Identifiant reçu par la route.
  final String devisId;

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final devis = store.findDevis(devisId);
        final user = store.session;
        if (!store.providerView ||
            devis == null ||
            user == null ||
            devis.prestataireId != user.id) {
          return const AccesRefuse(
            title: 'Devis',
            message: 'Ce devis n\'est pas accessible.',
          );
        }

        return DevisContratsFrame(
          title: devis.numero,
          child: ListView(
            children: [
              Text(
                'DEVIS N° ${devis.numero}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              StatutTexte.devis(devis.statut),
              const SizedBox(height: 12),
              InfoLigne('Client', store.nomDe(devis.clientId)),
              InfoLigne('Service', devis.service),
              InfoLigne('Lieu', devis.lieu),
              InfoLigne('Date', formatDate(devis.date)),
              InfoLigne('Heure', devis.heure),
              InfoLigne('Durée estimée', devis.dureeEstimee),
              const SizedBox(height: 8),
              MontantBlock(
                prixBase: devis.prixBase,
                options: devis.options,
                distanceKm: devis.distanceKm,
                prixParKm: devis.prixParKm,
              ),
              const SectionTitre('Conditions'),
              Text(devis.conditions.isEmpty ? '—' : devis.conditions),
              const SectionTitre('Éléments inclus'),
              Text(devis.elementsInclus.isEmpty ? '—' : devis.elementsInclus),
              const SectionTitre('Éléments non inclus'),
              Text(devis.elementsNonInclus.isEmpty ? '—' : devis.elementsNonInclus),
              const SizedBox(height: 16),
              const RemarqueDevis(),
              if (devis.statut == StatutDevis.accepte) ...[
                const SizedBox(height: 16),
                const Text('✓ Devis accepté par le client'),
                if (devis.contratId != null) ...[
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => openDevisPage(
                      context,
                      DevisContratsRoutes.detailContratPrestataire,
                      arguments: devis.contratId,
                    ),
                    child: const Text('Voir le contrat'),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
