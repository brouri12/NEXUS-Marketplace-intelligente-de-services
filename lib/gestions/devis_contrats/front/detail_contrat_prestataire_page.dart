import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/modification_contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Détail d'un contrat pour le prestataire, avec sa signature.
class DetailContratPrestatairePage extends StatelessWidget {
  /// Affiche le contrat [contratId].
  const DetailContratPrestatairePage({super.key, required this.contratId});

  /// Identifiant reçu par la route.
  final String contratId;

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final contrat = store.findContrat(contratId);
        final user = store.session;
        if (!store.providerView ||
            contrat == null ||
            user == null ||
            contrat.prestataireId != user.id) {
          return const AccesRefuse(
            title: 'Contrat',
            message: 'Ce contrat n\'est pas accessible.',
          );
        }
        final devis = store.devisDuContrat(contrat);
        final options = contrat.options.map((option) => option.label).join(', ');
        final attente = store.modificationEnAttente(contrat.id);
        final historique = store.modificationsDe(contrat.id);

        return DevisContratsFrame(
          title: contrat.numero,
          child: ListView(
            children: [
              Text(
                'CONTRAT N° ${contrat.numero}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InfoLigne('Devis', devis?.numero ?? '—'),
              StatutTexte.contrat(contrat.statut),
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
              InfoLigne('Prix accepté', formatDt(contrat.prixAccepte)),
              const SectionTitre('CONDITIONS'),
              Text(contrat.conditions.isEmpty ? '—' : contrat.conditions),
              const SectionTitre('SIGNATURE PRESTATAIRE'),
              Text(contrat.signaturePrestataire ? 'Prestataire : ✓ Signé' : 'Prestataire : Non signé'),
              Text(contrat.signatureClient ? 'Client : ✓ Signé' : 'Client : En attente'),
              if (!contrat.signaturePrestataire) ...[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    final error = store.signerPrestataire(contrat.id);
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  },
                  child: const Text('Signer'),
                ),
              ],
              if (contrat.deuxSignatures) CachetNexus(numero: contrat.numero),
              const SizedBox(height: 16),
              if (attente != null)
                Text(
                  'Proposition en attente du client. Nouveau total : ${formatDt(attente.nouveauTotal)}.',
                )
              else
                FilledButton(
                  onPressed: () => openDevisPage(
                    context,
                    DevisContratsRoutes.proposer,
                    arguments: contrat.id,
                  ),
                  child: const Text('Proposer une modification'),
                ),
              if (historique.isNotEmpty && attente == null) ...[
                const SizedBox(height: 12),
                Text(_bilan(historique.first)),
              ],
            ],
          ),
        );
      },
    );
  }

  String _bilan(ModificationContrat modification) {
    return switch (modification.statut) {
      StatutModification.acceptee =>
        '✓ Modification acceptée. Nouveau montant : ${formatDt(modification.nouveauTotal)}.',
      StatutModification.refusee =>
        'Modification refusée. Le contrat initial reste applicable.',
      StatutModification.proposee => 'Proposition en attente du client.',
    };
  }
}
