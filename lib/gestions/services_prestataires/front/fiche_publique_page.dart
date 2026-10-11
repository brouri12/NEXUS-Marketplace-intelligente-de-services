import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/core/ui/nexus_ui.dart';
import 'package:flutter_android_app/gestions/communication_reclamation/back/communication_store.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/composants.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/demander_devis_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/modele.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/texte.dart';

/// Fiche lue par le client. Aucun crayon sur cette page.
///
/// Le catalogue et la marketplace l'ouvrent pour [prestataireId].
/// [permettreApercu] sert au prestataire, depuis son tableau de bord.
class FichePubliquePage extends StatelessWidget {
  /// Affiche la fiche de [prestataireId], ou celle du compte ouvert.
  const FichePubliquePage({
    super.key,
    required this.etat,
    this.prestataireId,
    this.permettreApercu = false,
    this.lieuInitial = '',
    this.onDemandeEnvoyee,
  });

  /// Offres et prestataires.
  final ServicesPrestatairesEtat etat;

  /// Prestataire affiché. Absent, c'est le compte ouvert.
  final String? prestataireId;

  /// Vrai sur l'aperçu ouvert depuis le tableau de bord.
  final bool permettreApercu;

  /// Lieu déjà connu par la marketplace.
  final String lieuInitial;

  /// Prévient la marketplace qu'une demande de devis est partie.
  final void Function(OffreService service)? onDemandeEnvoyee;

  @override
  Widget build(BuildContext context) {
    final id = prestataireId ?? etat.prestataireConnecteId;
    return ListenableBuilder(
      listenable: Listenable.merge([etat, communicationStore]),
      builder: (context, _) {
        final services = etat.servicesDeLaFiche(
          apercu: permettreApercu,
          prestataireId: id,
        );
        final avis = communicationStore.avisPublicsDe(id);
        final note = communicationStore.noteMoyenne(id);
        return Scaffold(
          appBar: AppBar(title: const Text('Fiche publique')),
          body: Column(
            children: [
              if (permettreApercu) _apercu(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    _entete(context, id),
                    const SizedBox(height: 20),
                    const TitreSection('Services'),
                    const SizedBox(height: 12),
                    if (services.isEmpty)
                      const Legende('Aucun service publié.')
                    else
                      for (final service in services) _service(context, service),
                    const SizedBox(height: 8),
                    const TitreSection('Fourchette de prix'),
                    const SizedBox(height: 12),
                    _prix(context, id),
                    const SizedBox(height: 20),
                    const TitreSection('Note'),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: note == null
                            ? const Legende('Pas encore de note.')
                            : Text(
                                '${note.toStringAsFixed(1)} / 5 · ${avis.length} avis',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: IndigoOrChart.orTexte,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const TitreSection('Derniers avis'),
                    const SizedBox(height: 12),
                    if (avis.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Legende('Pas encore d\'avis.'),
                        ),
                      )
                    else
                      for (final item in avis.take(3))
                        Card(
                          child: ListTile(
                            title: Text('★' * item.note),
                            subtitle: Text(
                              '${item.texte}\n${communicationStore.nomDe(item.clientId)} · ${formatDate(item.publieLe)}',
                            ),
                            isThreeLine: true,
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BarreBasse(
            child: BoutonLarge(
              libelle: 'Demander un devis',
              onPressed: services.isEmpty ? null : () => _demander(context, services),
            ),
          ),
        );
      },
    );
  }

  Widget _apercu(BuildContext context) {
    return Material(
      color: IndigoOrChart.primaireConteneur,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Text(
          'Aperçu client : un service sans tarif n\'apparaît pas pour le client.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: IndigoOrChart.onPrimaireConteneur,
          ),
        ),
      ),
    );
  }

  Widget _entete(BuildContext context, String id) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: IndigoOrChart.primaireConteneur,
              child: Icon(
                Icons.person,
                size: 32,
                color: IndigoOrChart.primaire,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(etat.nomPrestataire(id), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Legende(etat.zoneDe(id)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _service(BuildContext context, OffreService service) {
    final theme = Theme.of(context);
    final tarif = service.tarif;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.nom, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Legende(
              '${libelleVehicule(service.vehicule)} · ${service.libelleEquipe}',
            ),
            if (tarif != null) ...[
              const SizedBox(height: 4),
              Legende(
                '${tarif.montantDt} DT · ${libelleTypeTarif(tarif.type).toLowerCase()}',
              ),
            ],
            if (permettreApercu && tarif == null) ...[
              const SizedBox(height: 8),
              const Pastille.sansTarif(),
            ],
            if (service.competencesVisibles.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final competence in service.competencesVisibles)
                    Chip(
                      label: Text(competence.libelle),
                      backgroundColor: IndigoOrChart.orConteneur,
                      labelStyle: const TextStyle(
                        color: IndigoOrChart.onOrConteneur,
                      ),
                      side: BorderSide.none,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _prix(BuildContext context, String id) {
    final theme = Theme.of(context);
    final vide = etat.fourchetteDe(id) == null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          etat.libelleFourchetteDe(id),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: vide
                ? theme.colorScheme.onSurfaceVariant
                : IndigoOrChart.orTexte,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _demander(BuildContext context, List<OffreService> services) async {
    if (permettreApercu) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aperçu : le client demande son devis ici.')),
      );
      return;
    }
    final avecTarif = [for (final service in services) if (service.tarif != null) service];
    if (avecTarif.isEmpty) return;
    final choisi = avecTarif.length == 1
        ? avecTarif.first
        : await choisirNexus<OffreService>(
            context,
            titre: 'Quel service ?',
            icone: Icons.handyman_outlined,
            options: [for (final service in avecTarif) (service, service.nom)],
          );
    if (choisi == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DemanderDevisPage(
          service: etat.versCatalogue(choisi),
          lieuInitial: lieuInitial,
          onEnvoyee: onDemandeEnvoyee == null ? null : () => onDemandeEnvoyee!(choisi),
        ),
      ),
    );
  }
}
