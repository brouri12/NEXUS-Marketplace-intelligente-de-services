import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/messages_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/modification_contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';
import 'package:flutter_android_app/gestions/logistique/front/trajet_du_contrat.dart';

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
              const SectionTitre('PAIEMENT'),
              _StatutPaiement(contrat: contrat),
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
              OutlinedButton.icon(
                onPressed: () => ouvrirDiscussion(context, 'c:${contrat.id}'),
                icon: const Icon(Icons.forum_outlined),
                label: const Text('Discuter'),
              ),
              TrajetDuContrat(contrat: contrat),
              if (contrat.statut == StatutContrat.valide) ...[
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => _faire(context, store.demarrerPrestation(contrat.id)),
                  child: const Text('Démarrer la prestation'),
                ),
              ],
              if (contrat.statut == StatutContrat.enCours) ...[
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => _faire(context, store.terminerPrestation(contrat.id)),
                  child: const Text('Terminer la prestation'),
                ),
              ],
              const SizedBox(height: 16),
              if (attente != null)
                Text(
                  'Proposition en attente du client. Nouveau total : ${formatDt(attente.nouveauTotal)}.',
                )
              else if (contrat.statut == StatutContrat.valide ||
                  contratEnAttenteSignature(contrat.statut))
                FilledButton(
                  onPressed: () => openDevisPage(
                    context,
                    DevisContratsRoutes.proposer,
                    arguments: contrat.id,
                  ),
                  child: const Text('Proposer une modification'),
                ),
              if (!contrat.signaturePrestataire &&
                  (contrat.statut == StatutContrat.valide ||
                      contratEnAttenteSignature(contrat.statut))) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _faire(context, store.annulerContrat(contrat.id)),
                  child: const Text('Annuler le contrat'),
                ),
              ],
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

  void _faire(BuildContext context, String? error) {
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
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

/// Affiche le statut de paiement avec icône et couleur distincte selon le mode.
class _StatutPaiement extends StatelessWidget {
  const _StatutPaiement({required this.contrat});

  final Contrat contrat;

  @override
  Widget build(BuildContext context) {
    // Le client n'a pas encore signé
    if (!contrat.signatureClient) {
      return _tuile(
        icone: Icons.hourglass_empty_outlined,
        couleur: IndigoOrChart.texteMuted,
        texte: 'En attente de la signature du client.',
        detail: null,
      );
    }

    return switch (contrat.modePaiement) {
      ModePaiement.aucun => _tuile(
        icone: Icons.schedule_outlined,
        couleur: IndigoOrChart.attente,
        texte: 'Le client n\'a pas encore choisi son mode de paiement.',
        detail: null,
      ),
      ModePaiement.aLivraison => _tuile(
        icone: Icons.local_shipping_outlined,
        couleur: IndigoOrChart.attente,
        texte: 'Paiement à la livraison',
        detail: 'Le client règle en espèces à votre arrivée.',
      ),
      ModePaiement.enLigne => _tuile(
        icone: Icons.check_circle_outline,
        couleur: IndigoOrChart.succes,
        texte: 'Déjà payé',
        detail: 'Le client a réglé en ligne. Aucun encaissement requis.',
      ),
    };
  }

  Widget _tuile({
    required IconData icone,
    required Color couleur,
    required String texte,
    required String? detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: couleur.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: couleur.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: couleur, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  texte,
                  style: TextStyle(
                    color: couleur,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: const TextStyle(
                      color: IndigoOrChart.texteMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
