import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Devis destinés au client connecté.
class MesDevisClientPage extends StatelessWidget {
  /// Liste les devis du client ouvert.
  const MesDevisClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (!store.clientView) {
          return const AccesRefuse(
            title: 'Mes devis',
            message: 'Cette liste est réservée à un client.',
          );
        }
        final devis = store.devisClient();
        return DevisContratsFrame(
          title: 'Mes devis',
          child: ListView(
            children: [
              if (devis.isEmpty)
                const Text('Aucun devis pour le moment.')
              else
                for (final item in devis)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DEVIS ${item.numero}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          InfoLigne('Prestataire', store.nomDe(item.prestataireId)),
                          InfoLigne('Service', item.service),
                          InfoLigne('Prix', formatDt(item.total)),
                          InfoLigne('Date', formatDate(item.date)),
                          StatutTexte.devis(item.statut),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => openDevisPage(
                              context,
                              DevisContratsRoutes.detailDevisClient,
                              arguments: item.id,
                            ),
                            child: const Text('Voir le devis'),
                          ),
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
