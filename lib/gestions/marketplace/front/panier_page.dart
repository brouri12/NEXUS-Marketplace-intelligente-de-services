import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/core/ui/nexus_ui.dart';
import 'package:flutter_android_app/gestions/marketplace/back/marketplace_store.dart';
import 'package:flutter_android_app/gestions/marketplace/back/produit.dart';
import 'package:flutter_android_app/gestions/marketplace/front/composants_boutique.dart';

/// Panier du client et passage de commande.
class PanierPage extends StatefulWidget {
  /// Affiche le panier de [store].
  const PanierPage({super.key, required this.store});

  /// Boutique.
  final MarketplaceStore store;

  @override
  State<PanierPage> createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  late final _adresse = TextEditingController(text: widget.store.session?.city ?? '');
  var _erreur = '';

  @override
  void dispose() {
    _adresse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final items = store.panier();
        final vendeurs = {for (final (produit, _) in items) produit.vendeurId};
        return Scaffold(
          appBar: AppBar(title: const Text('Panier')),
          backgroundColor: IndigoOrChart.fond,
          bottomNavigationBar: items.isEmpty
              ? null
              : BarreAction(
                  label: 'Commander',
                  icone: Icons.check,
                  onPressed: _commander,
                  secondaire: Row(
                    children: [
                      Text('Total', style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Text(
                        formatPrix(store.totalPanier),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: IndigoOrChart.orTexte,
                        ),
                      ),
                    ],
                  ),
                ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (items.isEmpty) const ListeVide('Votre panier est vide.'),
              for (final (produit, quantite) in items)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        VignetteProduit(produit: produit, taille: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(produit.nom),
                              Text(
                                '${formatPrix(produit.prixDt)} × $quantite = '
                                '${formatPrix(produit.prixDt * quantite)}',
                                style: const TextStyle(color: IndigoOrChart.texteMuted),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Retirer un',
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _changer(produit, quantite - 1),
                        ),
                        Text('$quantite'),
                        IconButton(
                          tooltip: 'Ajouter un',
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _changer(produit, quantite + 1),
                        ),
                      ],
                    ),
                  ),
                ),
              if (items.isNotEmpty) ...[
                const SizedBox(height: 8),
                if (vendeurs.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${vendeurs.length} vendeurs : une commande sera créée pour chacun.',
                      style: const TextStyle(color: IndigoOrChart.texteMuted),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('panier-adresse'),
                  controller: _adresse,
                  decoration: const InputDecoration(
                    labelText: 'Adresse de livraison',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_erreur.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_erreur, style: const TextStyle(color: IndigoOrChart.erreur)),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  void _changer(Produit produit, int quantite) {
    final erreur = widget.store.changerQuantite(produit.id, quantite);
    if (erreur != null) afficherMessage(context, erreur);
  }

  void _commander() {
    final erreur = widget.store.commander(_adresse.text);
    if (erreur != null) {
      setState(() => _erreur = erreur);
      return;
    }
    afficherMessage(context, 'Commande envoyée. Suivez-la dans « Mes commandes ».');
    Navigator.of(context).pop();
  }
}
