import 'package:flutter/material.dart';

import 'package:flutter_android_app/gestions/devis_contrats/back/modification_contrat.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_frame.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_contrats_routes.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';

/// Le client accepte ou refuse une modification de contrat.
class ModificationClientPage extends StatelessWidget {
  /// Affiche la proposition du contrat [contratId].
  const ModificationClientPage({super.key, required this.contratId});

  /// Identifiant reçu par la route.
  final String contratId;

  @override
  Widget build(BuildContext context) {
    final store = DevisStoreScope.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final contrat = store.findContrat(contratId);
        final user = store.session;
        if (!store.clientView || contrat == null || user == null || contrat.clientId != user.id) {
          return const AccesRefuse(
            title: 'Modification',
            message: 'Cette proposition n\'est pas accessible.',
          );
        }
        final modification =
            store.modificationEnAttente(contrat.id) ??
            store.modificationsDe(contrat.id).firstOrNull;
        if (modification == null) {
          return const AccesRefuse(
            title: 'Modification',
            message: 'Aucune proposition pour ce contrat.',
          );
        }
        final ouverte = modification.statut == StatutModification.proposee;

        return DevisContratsFrame(
          title: 'Modification du contrat',
          child: ListView(
            children: [
              Text(
                'MODIFICATION DU CONTRAT',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              InfoLigne('Contrat', contrat.numero),
              InfoLigne('Prestataire', store.nomDe(contrat.prestataireId)),
              InfoLigne('Prix actuel', formatDt(modification.prixActuel)),
              InfoLigne('Motif', modification.motif),
              InfoLigne('Supplément', formatDt(modification.supplement)),
              Text(
                'Nouveau total : ${formatDt(modification.nouveauTotal)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InfoLigne(
                'Nouvelles conditions',
                modification.nouvellesConditions.isEmpty
                    ? 'Inchangées'
                    : modification.nouvellesConditions,
              ),
              const SizedBox(height: 12),
              if (ouverte) ...[
                const Text(remarqueModificationClient),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => store.refuserModification(modification.id),
                        child: const Text('Refuser'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => store.accepterModification(modification.id),
                        child: const Text('Accepter'),
                      ),
                    ),
                  ],
                ),
              ],
              if (modification.statut == StatutModification.acceptee) ...[
                const Text('✓ Modification acceptée'),
                const SizedBox(height: 8),
                Text('Nouveau montant : ${formatDt(modification.nouveauTotal)}'),
              ],
              if (modification.statut == StatutModification.refusee)
                const Text(
                  'Modification refusée. Le contrat initial reste applicable.',
                ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  final navigator = Navigator.of(context);
                  if (navigator.canPop()) {
                    navigator.pop();
                    return;
                  }
                  openDevisPage(
                    context,
                    DevisContratsRoutes.detailContratClient,
                    arguments: contrat.id,
                  );
                },
                child: const Text('Retour au contrat'),
              ),
            ],
          ),
        );
      },
    );
  }
}
