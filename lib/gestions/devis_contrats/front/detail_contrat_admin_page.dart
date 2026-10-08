import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/modification_contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Lecture d'un contrat par l'admin, signatures et modifications comprises.
class DetailContratAdminPage extends StatelessWidget {
  /// Affiche le contrat [contratId].
  const DetailContratAdminPage({super.key, required this.contratId});

  /// Identifiant reçu par la route.
  final String contratId;

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final contrat = store.findContrat(contratId);
        if (!store.adminView || contrat == null) {
          return const AccesRefuse(
            title: 'Contrat',
            message: 'Ce contrat n\'est pas accessible.',
          );
        }
        final devis = store.devisDuContrat(contrat);
        final options = contrat.options.map((option) => option.label).join(', ');
        final modifications = store.modificationsDe(contrat.id);

        return DevisContratsFrame(
          title: contrat.numero,
          child: ListView(
            children: [
              Text(
                'CONTRAT N° ${contrat.numero}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              StatutTexte.contrat(contrat.statut),
              const SectionTitre('DEVIS ASSOCIÉ'),
              InfoLigne('Numéro', devis?.numero ?? '—'),
              const SectionTitre('CLIENT'),
              InfoLigne('Nom', store.nomDe(contrat.clientId)),
              InfoLigne('Téléphone', store.telephoneDe(contrat.clientId)),
              InfoLigne('Adresse', store.villeDe(contrat.clientId)),
              const SectionTitre('PRESTATAIRE'),
              InfoLigne('Nom', store.nomDe(contrat.prestataireId)),
              InfoLigne('Téléphone', store.telephoneDe(contrat.prestataireId)),
              InfoLigne('Zone', store.villeDe(contrat.prestataireId)),
              const SectionTitre('PRESTATION'),
              InfoLigne('Service', contrat.service),
              InfoLigne('Date', formatDate(contrat.date)),
              InfoLigne('Heure', contrat.heure),
              InfoLigne('Lieu', contrat.lieu),
              InfoLigne('Options', options),
              InfoLigne('Distance', formatKm(contrat.distanceKm)),
              InfoLigne('Montant', formatDt(contrat.prixAccepte)),
              const SectionTitre('CONDITIONS'),
              Text(contrat.conditions.isEmpty ? '—' : contrat.conditions),
              const SectionTitre('SIGNATURES'),
              Text(
                contrat.signaturePrestataire
                    ? 'Signature prestataire : ✓ Signé'
                    : 'Signature prestataire : Non signé',
              ),
              const SizedBox(height: 4),
              Text(
                contrat.signatureClient
                    ? 'Signature client : ✓ Signé'
                    : 'Signature client : Non signé',
              ),
              if (contrat.deuxSignatures) CachetNexus(numero: contrat.numero),
              const SectionTitre('MODIFICATIONS'),
              if (modifications.isEmpty)
                const Text('Aucune modification.')
              else
                for (final item in modifications)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(labelStatutModification(item.statut)),
                          const SizedBox(height: 8),
                          InfoLigne('Motif', item.motif),
                          InfoLigne('Supplément', formatDt(item.supplement)),
                          InfoLigne('Nouveau total', formatDt(item.nouveauTotal)),
                          InfoLigne(
                            'Conditions',
                            item.nouvellesConditions.isEmpty
                                ? 'Inchangées'
                                : item.nouvellesConditions,
                          ),
                          InfoLigne('Date', formatDate(item.creeeLe)),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
