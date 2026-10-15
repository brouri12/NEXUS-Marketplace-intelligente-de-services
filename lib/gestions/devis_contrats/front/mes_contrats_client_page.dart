import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Contrats du client connecté.
class MesContratsClientPage extends StatelessWidget {
  /// Liste les contrats du client ouvert.
  const MesContratsClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (!store.clientView) {
          return const AccesRefuse(
            title: 'Mes contrats',
            message: 'Cette liste est réservée à un client.',
          );
        }
        final contrats = store.contratsClient();
        return DevisContratsFrame(
          title: 'Mes contrats',
          child: ListView(
            children: [
              if (contrats.isEmpty)
                const Text('Aucun contrat pour le moment.')
              else
                for (final contrat in contrats)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => openDevisPage(
                        context,
                        DevisContratsRoutes.detailContratClient,
                        arguments: contrat.id,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contrat.numero,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(store.nomDe(contrat.prestataireId)),
                            Text(contrat.service),
                            Text(formatDt(contrat.prixAccepte)),
                            Text(formatDate(contrat.date)),
                            const SizedBox(height: 8),
                            Text('Statut : ${labelStatutContrat(contrat.statut)}'),
                            if (store.modificationEnAttente(contrat.id) != null) ...[
                              const SizedBox(height: 8),
                              const Text('Une modification est en attente.'),
                            ],
                          ],
                        ),
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
