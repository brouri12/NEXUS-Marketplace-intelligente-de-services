import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/services_prestataires/front/composants.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/modele.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/texte.dart';

/// Tous les services, chacun affecté à un prestataire.
class TousLesServicesPage extends StatelessWidget {
  /// Affiche le catalogue porté par [etat].
  const TousLesServicesPage({super.key, required this.etat});

  /// Mémoire d'écran.
  final ServicesPrestatairesEtat etat;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: etat,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Tous les services')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Legende(
                'Chaque service reste dans le secteur du compte, et s\'affecte à un prestataire de ce profil.',
              ),
              for (final prestataire in etat.prestataires) ...[
                const SizedBox(height: 20),
                TitreSection(etat.nomPrestataire(prestataire.id)),
                const SizedBox(height: 12),
                for (final service in etat.servicesDe(prestataire.id))
                  _carte(context, service),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _carte(BuildContext context, OffreService service) {
    final theme = Theme.of(context);
    final tarif = service.tarif;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.nom, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(service.zone, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 2),
            Legende(
              '${libelleVehicule(service.vehicule)} · ${service.libelleEquipe}',
            ),
            if (tarif != null) ...[
              const SizedBox(height: 4),
              Legende(
                '${tarif.montantDt} DT · ${libelleTypeTarif(tarif.type).toLowerCase()}',
              ),
            ],
            const SizedBox(height: 4),
            Legende(service.resumeCompetences),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _affecter(context, service),
                child: const Text('Affecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _affecter(BuildContext context, OffreService service) async {
    final choix = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Affecter ${service.nom}'),
          children: [
            for (final prestataire in etat.prestatairesDuSecteur(service.secteur))
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(prestataire.id),
                child: Text(etat.nomPrestataire(prestataire.id)),
              ),
          ],
        );
      },
    );
    if (choix == null) {
      return;
    }
    etat.affecter(service.id, choix);
  }
}
