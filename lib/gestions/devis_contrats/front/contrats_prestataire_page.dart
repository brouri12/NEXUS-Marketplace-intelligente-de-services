import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Contrats du prestataire connecté.
class ContratsPrestatairePage extends StatelessWidget {
  /// Liste les contrats du prestataire ouvert.
  const ContratsPrestatairePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (!store.providerView) {
          return const AccesRefuse(
            title: 'Contrats',
            message: 'Cette liste est réservée à un prestataire.',
          );
        }
        final contrats = store.contratsPrestataire();
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
                        DevisContratsRoutes.detailContratPrestataire,
                        arguments: contrat.id,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Contrat : ${contrat.numero}'),
                            const SizedBox(height: 8),
                            InfoLigne('Client', store.nomDe(contrat.clientId)),
                            InfoLigne('Service', contrat.service),
                            InfoLigne('Prix', formatDt(contrat.prixAccepte)),
                            InfoLigne('Date', formatDate(contrat.date)),
                            InfoLigne('Statut', labelStatutContrat(contrat.statut)),
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
