import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Lecture d'un devis par l'admin.
class DetailDevisAdminPage extends StatelessWidget {
  /// Affiche le devis [devisId].
  const DetailDevisAdminPage({super.key, required this.devisId});

  /// Identifiant reçu par la route.
  final String devisId;

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final devis = store.findDevis(devisId);
        if (!store.adminView || devis == null) {
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
              InfoLigne('Téléphone client', store.telephoneDe(devis.clientId)),
              InfoLigne('Prestataire', store.nomDe(devis.prestataireId)),
              InfoLigne('Téléphone prestataire', store.telephoneDe(devis.prestataireId)),
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
            ],
          ),
        );
      },
    );
  }
}
