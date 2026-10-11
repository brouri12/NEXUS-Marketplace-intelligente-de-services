import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/services_prestataires/front/composants.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/formulaire_service_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/modele.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/texte.dart';

/// Liste des offres du prestataire.
class MesServicesPage extends StatelessWidget {
  /// Affiche les offres de [etat].
  const MesServicesPage({super.key, required this.etat});

  /// Mémoire d'écran.
  final ServicesPrestatairesEtat etat;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: etat,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Mes services')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Legende(
                'Profil du compte : Déménagement. Masquer retire le service des résultats sans effacer les contrats passés.',
              ),
              const SizedBox(height: 16),
              for (final service in etat.servicesConnecte) _carte(context, service),
            ],
          ),
          bottomNavigationBar: BarreBasse(
            child: BoutonLarge(
              libelle: 'Ajouter un service',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => FormulaireServicePage(etat: etat),
                  ),
                );
              },
            ),
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
                if (service.enAttente)
                  const Pastille.attente()
                else if (service.motifRefus != null)
                  const Pastille.refuse()
                else if (service.publie)
                  const Pastille.actif()
                else
                  const Pastille.masque(),
              ],
            ),
            const SizedBox(height: 4),
            Text(service.zone, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 2),
            Legende(
              '${libelleVehicule(service.vehicule)} · ${service.libelleEquipe}',
            ),
            if (service.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                service.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Legende(service.resumeCompetences),
            if (service.motifRefus != null) ...[
              const SizedBox(height: 4),
              Legende(service.motifRefus!),
            ],
            if (service.approuve)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    if (service.publie) {
                      etat.masquer(service.id);
                    } else {
                      etat.afficher(service.id);
                    }
                  },
                  child: Text(service.publie ? 'Masquer' : 'Afficher'),
                ),
              )
            else if (service.enAttente)
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8, right: 8),
                  child: Legende('En attente d\'approbation'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
