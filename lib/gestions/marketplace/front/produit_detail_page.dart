import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/core/ui/nexus_ui.dart';
import 'package:flutter_android_app/gestions/marketplace/back/marketplace_store.dart';
import 'package:flutter_android_app/gestions/marketplace/back/produit.dart';
import 'package:flutter_android_app/gestions/marketplace/front/composants_boutique.dart';
import 'package:flutter_android_app/gestions/marketplace/front/produit_form_page.dart';

/// Fiche d'un produit : achat pour le client, gestion pour le vendeur.
class ProduitDetailPage extends StatefulWidget {
  /// Ouvre le produit [produitId].
  const ProduitDetailPage({super.key, required this.store, required this.produitId});

  /// Boutique.
  final MarketplaceStore store;

  /// Produit affiché.
  final String produitId;

  @override
  State<ProduitDetailPage> createState() => _ProduitDetailPageState();
}

class _ProduitDetailPageState extends State<ProduitDetailPage> {
  var _quantite = 1;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final produit = store.find(widget.produitId);
        if (produit == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Produit')),
            body: const ListeVide('Ce produit n\'existe plus.'),
          );
        }
        final acheter = store.acheteurView &&
            produit.disponible &&
            produit.vendeurId != store.session?.id;
        final restant = produit.stock - store.dansLePanier(produit.id);
        return Scaffold(
          appBar: AppBar(title: const Text('Produit')),
          backgroundColor: IndigoOrChart.fond,
          bottomNavigationBar: acheter
              ? BarreAction(
                  label: 'Ajouter au panier',
                  icone: Icons.add_shopping_cart,
                  actif: restant > 0,
                  onPressed: () {
                    final erreur = store.ajouterAuPanier(produit.id, _quantite);
                    afficherMessage(context, erreur ?? 'Ajouté au panier.');
                    if (erreur == null) setState(() => _quantite = 1);
                  },
                  secondaire: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.outlined(
                        tooltip: 'Moins',
                        onPressed: _quantite > 1 ? () => setState(() => _quantite--) : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$_quantite', style: Theme.of(context).textTheme.titleLarge),
                      ),
                      IconButton.outlined(
                        tooltip: 'Plus',
                        onPressed: _quantite < restant ? () => setState(() => _quantite++) : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                )
              : null,
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(child: VignetteProduit(produit: produit, taille: 120)),
              const SizedBox(height: 16),
              Text(produit.nom, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                '${labelCategorie(produit.categorie)} · vendu par ${store.nomVendeur(produit.vendeurId)}',
                style: const TextStyle(color: IndigoOrChart.texteMuted),
              ),
              const SizedBox(height: 12),
              Text(
                '${formatPrix(produit.prixDt)} / ${produit.unite}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: IndigoOrChart.orTexte,
                ),
              ),
              const SizedBox(height: 12),
              Text(produit.description.isEmpty ? 'Pas de description.' : produit.description),
              const SizedBox(height: 12),
              Text(
                !produit.actif
                    ? 'Retiré du catalogue.'
                    : produit.stock == 0
                    ? 'Épuisé.'
                    : '${produit.stock} en stock.',
                style: TextStyle(
                  color: produit.disponible ? IndigoOrChart.succes : IndigoOrChart.erreur,
                ),
              ),
              if (acheter && store.dansLePanier(produit.id) > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${store.dansLePanier(produit.id)} déjà dans votre panier.',
                      style: const TextStyle(color: IndigoOrChart.texteMuted),
                    ),
                  ),
              if (store.peutGerer(produit)) ...[
                const Divider(height: 32),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => ProduitFormPage(store: store, produit: produit),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Modifier'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => store.basculerVente(produit.id),
                      icon: Icon(
                        produit.actif ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      label: Text(produit.actif ? 'Retirer de la vente' : 'Remettre en vente'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: IndigoOrChart.erreur),
                      onPressed: () => _supprimer(produit),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Supprimer'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _supprimer(Produit produit) async {
    final ok = await confirmerNexus(
      context,
      titre: 'Supprimer « ${produit.nom} » ?',
      message: 'Il disparaît du catalogue. Les commandes passées restent.',
      confirmer: 'Supprimer',
      icone: Icons.delete_outline,
      danger: true,
    );
    if (ok != true || !mounted) return;
    final erreur = widget.store.supprimerProduit(produit.id);
    if (erreur == null) {
      Navigator.of(context).pop();
    } else {
      afficherMessage(context, erreur);
    }
  }
}
