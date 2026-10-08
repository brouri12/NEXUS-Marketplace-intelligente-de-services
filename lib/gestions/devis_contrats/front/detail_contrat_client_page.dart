import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_store.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/avis_page.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/messages_page.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/front/reclamations_page.dart';
import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/zone_signature.dart';

/// Détail d'un contrat pour le client, avec sa signature.
class DetailContratClientPage extends StatefulWidget {
  /// Affiche le contrat [contratId].
  const DetailContratClientPage({super.key, required this.contratId});

  /// Identifiant reçu par la route.
  final String contratId;

  @override
  State<DetailContratClientPage> createState() => _DetailContratClientPageState();
}

class _DetailContratClientPageState extends State<DetailContratClientPage> {
  var _trace = false;
  var _error = '';

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([store, communicationStore]),
      builder: (context, _) {
        final contrat = store.findContrat(widget.contratId);
        final user = store.session;
        if (!store.clientView ||
            contrat == null ||
            user == null ||
            contrat.clientId != user.id) {
          return const AccesRefuse(
            title: 'Contrat',
            message: 'Ce contrat n\'est pas accessible.',
          );
        }
        final devis = store.devisDuContrat(contrat);
        final options = contrat.options.map((option) => option.label).join(', ');
        final attente = store.modificationEnAttente(contrat.id);
        final peutSigner = contrat.signaturePrestataire && !contrat.signatureClient;

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
              if (peutSigner) ...[
                const SizedBox(height: 16),
                ZoneSignature(onChanged: (value) => setState(() => _trace = value)),
                const SizedBox(height: 12),
                ErreurFormulaire(message: _error),
                FilledButton(
                  onPressed: _trace ? () => _signer(context) : null,
                  child: const Text('Signer le contrat'),
                ),
              ],
              if (contrat.deuxSignatures) CachetNexus(numero: contrat.numero),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => ouvrirDiscussion(context, 'c:${contrat.id}'),
                icon: const Icon(Icons.forum_outlined),
                label: const Text('Discuter'),
              ),
              if (communicationStore.peutEvaluer(contrat.id)) ...[
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AvisFormPage(contratId: contrat.id),
                    ),
                  ),
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Rédiger un avis'),
                ),
              ],
              if (communicationStore.peutReclamer(contrat.id)) ...[
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ReclamationFormPage(contratId: contrat.id),
                    ),
                  ),
                  icon: const Icon(Icons.report_outlined),
                  label: const Text('Déposer une réclamation'),
                ),
              ],
              if (_annulable(contrat.statut)) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    final error = store.annulerContrat(contrat.id);
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  },
                  child: const Text('Annuler le contrat'),
                ),
              ],
              if (attente != null) ...[
                const SizedBox(height: 16),
                const Text('Le prestataire propose une modification.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => openDevisPage(
                    context,
                    DevisContratsRoutes.modificationClient,
                    arguments: contrat.id,
                  ),
                  child: const Text('Voir la proposition'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  bool _annulable(StatutContrat statut) {
    return statut == StatutContrat.attenteSignaturePrestataire ||
        statut == StatutContrat.attenteSignatureClient ||
        statut == StatutContrat.valide;
  }

  void _signer(BuildContext context) {
    if (!_trace) {
      setState(() => _error = 'Signez dans la zone prévue.');
      return;
    }
    final error = DevisStoreScope.of(context).signerClient(widget.contratId);
    setState(() => _error = error ?? '');
  }
}
