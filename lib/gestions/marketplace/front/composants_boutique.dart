import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/gestions/devis_contrats/front/devis_presentation.dart';
import 'package:flutter_android_app/gestions/marketplace/back/marketplace_store.dart';
import 'package:flutter_android_app/gestions/marketplace/back/produit.dart';
import 'package:flutter_android_app/gestions/marketplace/front/commande_detail_page.dart';
import 'package:flutter_android_app/gestions/marketplace/front/produit_detail_page.dart';

/// Couleur du statut [statut].
Color couleurCommande(StatutCommande statut) {
  return switch (statut) {
    StatutCommande.enAttente => IndigoOrChart.attente,
    StatutCommande.confirmee || StatutCommande.expediee => IndigoOrChart.primaire,
    StatutCommande.livree => IndigoOrChart.succes,
    StatutCommande.annulee => IndigoOrChart.erreur,
  };
}

/// Pastille colorée.
class Pastille extends StatelessWidget {
  /// Affiche [texte] dans [couleur].
  const Pastille({super.key, required this.texte, required this.couleur});

  /// Texte court.
  final String texte;

  /// Couleur du texte et du fond.
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        texte,
        style: TextStyle(color: couleur, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Vignette d'un produit : l'icône de sa catégorie sur fond indigo.
class VignetteProduit extends StatelessWidget {
  /// Affiche la vignette de [produit].
  const VignetteProduit({super.key, required this.produit, this.taille = 56});

  /// Produit illustré.
  final Produit produit;

  /// Côté du carré.
  final double taille;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        color: IndigoOrChart.primaireConteneur,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconeCategorie(produit.categorie),
        color: IndigoOrChart.primaire,
        size: taille * 0.5,
      ),
    );
  }
}

/// Ligne de catalogue : produit, vendeur, prix et stock.
class ProduitTuile extends StatelessWidget {
  /// Affiche [produit].
  const ProduitTuile({super.key, required this.store, required this.produit});

  /// Boutique.
  final MarketplaceStore store;

  /// Produit affiché.
  final Produit produit;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => ouvrirProduit(context, store, produit.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              VignetteProduit(produit: produit),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(produit.nom, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '${store.nomVendeur(produit.vendeurId)} · ${produit.unite}',
                      style: const TextStyle(color: IndigoOrChart.texteMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          formatPrix(produit.prixDt),
                          style: const TextStyle(
                            color: IndigoOrChart.orTexte,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!produit.actif)
                          const Pastille(texte: 'RETIRÉ', couleur: IndigoOrChart.texteMuted)
                        else if (produit.stock == 0)
                          const Pastille(texte: 'ÉPUISÉ', couleur: IndigoOrChart.erreur)
                        else if (produit.stock <= 5)
                          Pastille(
                            texte: 'PLUS QUE ${produit.stock}',
                            couleur: IndigoOrChart.attente,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (store.acheteurView &&
                  produit.disponible &&
                  produit.vendeurId != store.session?.id)
                IconButton(
                  tooltip: 'Ajouter ${produit.nom} au panier',
                  icon: const Icon(Icons.add_shopping_cart_outlined),
                  color: IndigoOrChart.primaire,
                  onPressed: () {
                    final erreur = store.ajouterAuPanier(produit.id, 1);
                    afficherMessage(context, erreur ?? '${produit.nom} ajouté au panier.');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte d'une commande.
class CommandeTuile extends StatelessWidget {
  /// Affiche [commande], avec le client ou le vendeur selon [pourVendeur].
  const CommandeTuile({
    super.key,
    required this.store,
    required this.commande,
    this.pourVendeur = false,
  });

  /// Boutique.
  final MarketplaceStore store;

  /// Commande affichée.
  final Commande commande;

  /// Whether the card names the buyer instead of the seller.
  final bool pourVendeur;

  @override
  Widget build(BuildContext context) {
    final autre = pourVendeur
        ? 'Client : ${store.nomDe(commande.clientId)}'
        : 'Vendeur : ${store.nomVendeur(commande.vendeurId)}';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => CommandeDetailPage(store: store, commandeId: commande.id),
            ),
          );
        },
        leading: const Icon(Icons.receipt_long_outlined, color: IndigoOrChart.primaire),
        title: Row(
          children: [
            Expanded(child: Text(commande.numero)),
            Pastille(
              texte: labelStatutCommande(commande.statut),
              couleur: couleurCommande(commande.statut),
            ),
          ],
        ),
        subtitle: Text(
          '$autre\n${commande.articles} article(s) · ${formatPrix(commande.total)} · '
          '${formatDate(commande.creeLe)}',
        ),
        isThreeLine: true,
      ),
    );
  }
}

/// Ouvre la fiche du produit [id].
void ouvrirProduit(BuildContext context, MarketplaceStore store, String id) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => ProduitDetailPage(store: store, produitId: id),
    ),
  );
}

/// Message bref en bas de l'écran.
void afficherMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Liste vide, en gris.
class ListeVide extends StatelessWidget {
  /// Affiche [texte].
  const ListeVide(this.texte, {super.key});

  /// Message.
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          texte,
          textAlign: TextAlign.center,
          style: const TextStyle(color: IndigoOrChart.texteMuted),
        ),
      ),
    );
  }
}
