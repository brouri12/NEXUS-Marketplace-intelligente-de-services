import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/demande_devis.dart';
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
        final demandes = [
          for (final demande in store.demandesClient())
            if (demande.statut != StatutDemande.traitee) demande,
        ];
        return DevisContratsFrame(
          title: 'Mes devis',
          child: ListView(
            children: [
              if (demandes.isNotEmpty) ...[
                const SectionTitre('Demandes envoyées'),
                for (final demande in demandes)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.outbox_outlined),
                      title: Text('${demande.service} · ${store.nomPrestataire(demande)}'),
                      subtitle: Text(
                        '${formatDate(demande.date)} · ${demande.lieu}\n'
                        '${labelStatutDemande(demande.statut)} · estimation ${formatDt(demande.total)}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: 'Retirer la demande',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          final error = store.supprimerDemande(demande.id);
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error)),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                const SectionTitre('Devis reçus'),
              ],
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
