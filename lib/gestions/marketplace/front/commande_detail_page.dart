import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/core/ui/nexus_ui.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';
import 'package:flutter_android_app/gestions/marketplace/back/marketplace_store.dart';
import 'package:flutter_android_app/gestions/marketplace/back/produit.dart';
import 'package:flutter_android_app/gestions/marketplace/front/composants_boutique.dart';

/// Détail d'une commande, avec les étapes du vendeur.
class CommandeDetailPage extends StatelessWidget {
  /// Ouvre la commande [commandeId].
  const CommandeDetailPage({super.key, required this.store, required this.commandeId});

  /// Boutique.
  final MarketplaceStore store;

  /// Commande affichée.
  final String commandeId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final commande = store.findCommande(commandeId);
        if (commande == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Commande')),
            body: const ListeVide('Cette commande n\'existe plus.'),
          );
        }
        final vendeur = store.estVendeurDe(commande);
        final suivante = store.etapeSuivante(commande);
        final client = commande.clientId == store.session?.id;
        final annulable = commande.statut != StatutCommande.livree &&
            commande.statut != StatutCommande.annulee &&
            (vendeur || (client && commande.statut == StatutCommande.enAttente));
        final action = switch (suivante) {
          StatutCommande.confirmee => 'Confirmer la commande',
          StatutCommande.expediee => 'Marquer expédiée',
          StatutCommande.livree => 'Marquer livrée',
          _ => '',
        };
        return Scaffold(
          appBar: AppBar(title: Text(commande.numero)),
          backgroundColor: IndigoOrChart.fond,
          bottomNavigationBar: vendeur && suivante != null
              ? BarreAction(
                  label: action,
                  icone: Icons.arrow_forward,
                  onPressed: () => _afficher(context, store.avancer(commande.id)),
                )
              : null,
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatPrix(commande.total),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Pastille(
                    texte: labelStatutCommande(commande.statut),
                    couleur: couleurCommande(commande.statut),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Suivi(statut: commande.statut),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Ligne('Client', store.nomDe(commande.clientId)),
                      _Ligne('Vendeur', store.nomVendeur(commande.vendeurId)),
                      _Ligne('Livraison', commande.adresse),
                      _Ligne('Passée le', formatDate(commande.creeLe)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Articles', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final ligne in commande.lignes)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: store.find(ligne.produitId) == null
                        ? null
                        : () => ouvrirProduit(context, store, ligne.produitId),
                    title: Text(ligne.nom),
                    subtitle: Text('${formatPrix(ligne.prixDt)} × ${ligne.quantite}'),
                    trailing: Text(formatPrix(ligne.total)),
                  ),
                ),
              const SizedBox(height: 12),
              if (annulable) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: IndigoOrChart.erreur),
                  onPressed: () => _afficher(context, store.annuler(commande.id)),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Annuler la commande'),
                ),
              ],
              if (store.adminView &&
                  (commande.statut == StatutCommande.livree ||
                      commande.statut == StatutCommande.annulee)) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: IndigoOrChart.erreur),
                  onPressed: () {
                    final erreur = store.supprimerCommande(commande.id);
                    if (erreur == null) {
                      Navigator.of(context).pop();
                    } else {
                      afficherMessage(context, erreur);
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Supprimer la commande'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _afficher(BuildContext context, String? erreur) {
    if (erreur != null) afficherMessage(context, erreur);
  }
}

class _Suivi extends StatelessWidget {
  const _Suivi({required this.statut});

  final StatutCommande statut;

  static const _etapes = [
    StatutCommande.enAttente,
    StatutCommande.confirmee,
    StatutCommande.expediee,
    StatutCommande.livree,
  ];

  @override
  Widget build(BuildContext context) {
    if (statut == StatutCommande.annulee) {
      return const Text(
        'Commande annulée, les produits sont revenus en stock.',
        style: TextStyle(color: IndigoOrChart.erreur),
      );
    }
    final atteinte = _etapes.indexOf(statut);
    return Row(
      children: [
        for (var i = 0; i < _etapes.length; i++)
          Expanded(
            child: Column(
              children: [
                Icon(
                  i <= atteinte ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: i <= atteinte ? IndigoOrChart.succes : IndigoOrChart.contour,
                ),
                const SizedBox(height: 4),
                Text(
                  labelStatutCommande(_etapes[i]),
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne(this.libelle, this.valeur);

  final String libelle;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(libelle, style: const TextStyle(color: IndigoOrChart.texteMuted)),
          ),
          Expanded(child: Text(valeur)),
        ],
      ),
    );
  }
}
