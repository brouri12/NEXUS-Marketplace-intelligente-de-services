import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/contrat.dart';
import 'package:flutter_android_app/gestions/logistique/back/trajet.dart';
import 'package:flutter_android_app/gestions/logistique/front/logistique_detail_page.dart';
import 'package:flutter_android_app/gestions/logistique/front/logistique_form_page.dart';
import 'package:flutter_android_app/gestions/logistique/logistique_module.dart';

/// Bouton du contrat vers son trajet : suivre, ou planifier pour le prestataire.
class TrajetDuContrat extends StatelessWidget {
  /// Relie [contrat] à la logistique.
  const TrajetDuContrat({super.key, required this.contrat});

  /// Contrat affiché.
  final Contrat contrat;

  @override
  Widget build(BuildContext context) {
    final store = logistiqueStore;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final trajet = store.trajetDuContrat(contrat.id);
        final planifiable = store.contratsPlanifiables().any((item) => item.id == contrat.id);
        if (trajet != null && store.find(trajet.id) != null) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => LogistiqueDetailPage(store: store, trajetId: trajet.id),
                  ),
                );
              },
              icon: const Icon(Icons.local_shipping_outlined),
              label: Text('Suivre le trajet · ${labelTrajetStatus(trajet.status)}'),
            ),
          );
        }
        if (!planifiable) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => LogistiqueFormPage(store: store, contratId: contrat.id),
                ),
              );
            },
            icon: const Icon(Icons.route_outlined),
            label: const Text('Planifier le trajet'),
          ),
        );
      },
    );
  }
}
