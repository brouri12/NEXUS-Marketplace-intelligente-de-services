import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/composants.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/editeur_tarif_page.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/etat.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/modele.dart';
import 'package:flutter_android_app/gestions/services_prestataires/front/texte.dart';

/// Un tarif par service.
class TarifsPage extends StatelessWidget {
  /// Affiche les tarifs de [etat].
  const TarifsPage({super.key, required this.etat});

  /// Mémoire d'écran.
  final ServicesPrestatairesEtat etat;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: etat,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Tarifs')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Legende(
                'Ce montant préremplit le devis. Sans tarif, le service n\'apparaît pas dans les résultats.',
              ),
              const SizedBox(height: 16),
              for (final service in etat.servicesConnecte.where(
                (service) => service.approuve,
              ))
                _carte(context, service),
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
            Row(
              children: [
                Expanded(
                  child: Text(service.nom, style: theme.textTheme.titleMedium),
                ),
                if (!service.publie) const Pastille.masque(),
              ],
            ),
            const SizedBox(height: 4),
            Legende(service.zone),
            const SizedBox(height: 8),
            if (tarif == null)
              const Pastille.sansTarif()
            else
              Text(
                '${tarif.montantDt} DT · ${libelleTypeTarif(tarif.type).toLowerCase()}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: IndigoOrChart.orTexte,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (tarif != null) ...[
              const SizedBox(height: 4),
              Text(tarif.inclus, style: theme.textTheme.bodyMedium),
              if (tarif.enPlus.isNotEmpty) ...[
                const SizedBox(height: 2),
                Legende('En plus : ${tarif.enPlus.join(', ')}'),
              ],
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => EditeurTarifPage(
                        etat: etat,
                        serviceId: service.id,
                      ),
                    ),
                  );
                },
                child: Text(tarif == null ? 'Définir le tarif' : 'Modifier'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
