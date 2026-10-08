import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Devis préparés par le prestataire connecté.
class MesDevisPrestatairePage extends StatelessWidget {
  /// Liste les devis du prestataire ouvert.
  const MesDevisPrestatairePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (!store.providerView) {
          return const AccesRefuse(
            title: 'Mes devis',
            message: 'Cette liste est réservée à un prestataire.',
          );
        }
        final devis = store.devisPrestataire();
        return DevisContratsFrame(
          title: 'Mes devis',
          child: ListView(
            children: [
              if (devis.isEmpty)
                const Text('Aucun devis pour le moment.')
              else
                for (final item in devis)
                  FicheListe(
                    titre: '${item.numero} · ${store.nomDe(item.clientId)}',
                    icon: Icons.request_quote_outlined,
                    lignes: [
                      'Service : ${item.service}',
                      'Montant : ${formatDt(item.total)}',
                      'Date : ${formatDate(item.date)}',
                    ],
                    statut: StatutTexte.devis(item.statut),
                    onTap: () => openDevisPage(
                      context,
                      DevisContratsRoutes.detailDevisPrestataire,
                      arguments: item.id,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
