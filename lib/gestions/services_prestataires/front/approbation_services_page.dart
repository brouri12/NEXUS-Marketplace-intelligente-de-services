import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/ui/nexus_ui.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/composants.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/modele.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/texte.dart';

/// Demandes de service qu'un admin approuve ou refuse.
class ApprobationServicesPage extends StatelessWidget {
  /// Affiche les demandes en attente de [etat].
  const ApprobationServicesPage({super.key, required this.etat});

  /// Mémoire d'écran.
  final ServicesPrestatairesEtat etat;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: etat,
      builder: (context, _) {
        final demandes = etat.demandesEnAttente;
        final competences = etat.competencesAValider;
        return Scaffold(
          appBar: AppBar(title: const Text('Approbation')),
          body: demandes.isEmpty && competences.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Legende(
                      'Aucune demande en attente.',
                      alignement: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    const Legende(
                      'Un service ajouté par un prestataire reste invisible tant qu\'il n\'est pas approuvé.',
                    ),
                    const SizedBox(height: 16),
                    for (final service in demandes) _carte(context, service),
                    if (competences.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const TitreSection('Compétences saisies librement'),
                      const SizedBox(height: 8),
                      for (final (service, competence) in competences)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(competence.libelle),
                            subtitle: Text(
                              '${service.nom} · ${etat.nomPrestataire(service.prestataireId)}',
                            ),
                            trailing: Wrap(
                              children: [
                                IconButton(
                                  tooltip: 'Refuser ${competence.libelle}',
                                  onPressed: () => etat.retirerCompetence(
                                    service.id,
                                    competence.libelle,
                                  ),
                                  icon: const Icon(Icons.close),
                                ),
                                IconButton(
                                  tooltip: 'Valider ${competence.libelle}',
                                  onPressed: () => etat.validerCompetence(
                                    service.id,
                                    competence.libelle,
                                  ),
                                  icon: const Icon(Icons.check),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
        );
      },
    );
  }

  Widget _carte(BuildContext context, OffreService service) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(service.nom, style: theme.textTheme.titleMedium),
                ),
                const Pastille.attente(),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              etat.nomPrestataire(service.prestataireId),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 2),
            Legende(
              '${service.zone} · ${libelleVehicule(service.vehicule)} · ${service.libelleEquipe}',
            ),
            if (service.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(service.description, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () => _refuser(context, service),
                  child: const Text('Refuser'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => etat.approuver(service.id),
                  child: const Text('Approuver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refuser(BuildContext context, OffreService service) async {
    final motif = await showDialog<String>(
      context: context,
      builder: (context) => const _RefusDialog(),
    );
    if (motif == null) {
      return;
    }
    etat.refuser(service.id, motif);
  }
}

class _RefusDialog extends StatefulWidget {
  const _RefusDialog();

  @override
  State<_RefusDialog> createState() => _RefusDialogState();
}

class _RefusDialogState extends State<_RefusDialog> {
  final _motif = TextEditingController();

  @override
  void dispose() {
    _motif.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NexusDialog(
      titre: 'Refuser la demande',
      icone: Icons.block_outlined,
      message: 'Le prestataire verra le motif.',
      confirmer: 'Refuser',
      danger: true,
      confirmerActif: _motif.text.trim().isNotEmpty,
      onConfirmer: () => Navigator.of(context).pop(_motif.text.trim()),
      contenu: TextField(
        controller: _motif,
        textCapitalization: TextCapitalization.sentences,
        maxLength: 120,
        decoration: decorationChamp(context, label: 'Motif'),
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}
