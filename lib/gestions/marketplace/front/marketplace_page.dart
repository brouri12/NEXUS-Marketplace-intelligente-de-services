import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/core/ui/nexus_motion.dart';
import 'package:flutter_android_app/gestions/marketplace/back/marketplace_store.dart';
import 'package:flutter_android_app/gestions/marketplace/back/produit.dart';
import 'package:flutter_android_app/gestions/marketplace/front/composants_boutique.dart';
import 'package:flutter_android_app/gestions/marketplace/front/panier_page.dart';
import 'package:flutter_android_app/gestions/marketplace/front/produit_form_page.dart';

/// Boutique des produits utilisés par les services : cartons, câbles, râteaux…
class MarketplacePage extends StatelessWidget {
  /// Relie cet écran à [store].
  const MarketplacePage({super.key, required this.store});

  /// Produits, panier et commandes.
  final MarketplaceStore store;

  /// Nom affiché dans le menu.
  static const title = 'Marketplace';

  /// Responsabilités réservées à cette gestion.
  static const responsibilities = [
    'Produits par catégorie',
    'Panier et commandes',
    'Vente par les prestataires',
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final onglets = <(String, Widget)>[
          ('Catalogue', _Catalogue(store: store)),
          if (store.acheteurView)
            ('Mes commandes', _Commandes(store: store, commandes: store.mesCommandes())),
          if (store.vendeurView || store.adminView)
            (store.adminView ? 'Produits' : 'Mes produits', _MesProduits(store: store)),
          if (store.vendeurView)
            ('Ventes', _Commandes(store: store, commandes: store.ventes(), pourVendeur: true)),
          if (store.adminView)
            (
              'Commandes',
              _Commandes(store: store, commandes: store.toutesLesCommandes(), pourVendeur: true),
            ),
        ];
        return DefaultTabController(
          length: onglets.length,
          child: Scaffold(
            backgroundColor: IndigoOrChart.fond,
            appBar: AppBar(
              title: const Text(title),
              actions: [
                if (store.acheteurView)
                  IconButton(
                    tooltip: 'Panier',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => PanierPage(store: store),
                        ),
                      );
                    },
                    icon: Badge(
                      isLabelVisible: store.articlesPanier > 0,
                      label: Text('${store.articlesPanier}'),
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                  ),
              ],
              bottom: TabBar(
                isScrollable: onglets.length > 3,
                tabAlignment: onglets.length > 3 ? TabAlignment.start : null,
                tabs: [for (final (label, _) in onglets) Tab(text: label)],
              ),
            ),
            body: TabBarView(children: [for (final (_, vue) in onglets) vue]),
          ),
        );
      },
    );
  }
}

class _Catalogue extends StatefulWidget {
  const _Catalogue({required this.store});

  final MarketplaceStore store;

  @override
  State<_Catalogue> createState() => _CatalogueState();
}

class _CatalogueState extends State<_Catalogue> {
  final _recherche = TextEditingController();
  CategorieProduit? _categorie;

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final produits = store.catalogue(categorie: _categorie, recherche: _recherche.text);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          key: const Key('produit-recherche'),
          controller: _recherche,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Câble, palette, râteau…',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Tout'),
                selected: _categorie == null,
                onSelected: (_) => setState(() => _categorie = null),
              ),
              for (final categorie in CategorieProduit.values)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    avatar: Icon(iconeCategorie(categorie), size: 18),
                    label: Text(labelCategorie(categorie)),
                    selected: _categorie == categorie,
                    onSelected: (_) => setState(() => _categorie = categorie),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (produits.isEmpty) const ListeVide('Aucun produit ne correspond.'),
        for (var i = 0; i < produits.length; i++)
          Apparition(
            key: ValueKey(produits[i].id),
            index: i,
            child: ProduitTuile(store: store, produit: produits[i]),
          ),
      ],
    );
  }
}

class _MesProduits extends StatelessWidget {
  const _MesProduits({required this.store});

  final MarketplaceStore store;

  @override
  Widget build(BuildContext context) {
    final produits = store.mesProduits();
    final ruptures = produits.where((produit) => produit.actif && produit.stock == 0).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _Chiffre(valeur: '${produits.length}', libelle: 'Produits'),
                ),
                Expanded(
                  child: _Chiffre(valeur: '$ruptures', libelle: 'Épuisés'),
                ),
                Expanded(
                  child: _Chiffre(
                    valeur: formatPrix(store.chiffreAffaires),
                    libelle: 'Ventes livrées',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (context) => ProduitFormPage(store: store)),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Ajouter un produit'),
        ),
        const SizedBox(height: 12),
        if (produits.isEmpty)
          const ListeVide('Vous ne vendez encore aucun produit.'),
        for (var i = 0; i < produits.length; i++)
          Apparition(
            key: ValueKey(produits[i].id),
            index: i,
            child: ProduitTuile(store: store, produit: produits[i]),
          ),
      ],
    );
  }
}

class _Chiffre extends StatelessWidget {
  const _Chiffre({required this.valeur, required this.libelle});

  final String valeur;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valeur,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: IndigoOrChart.primaire),
        ),
        Text(libelle, style: const TextStyle(color: IndigoOrChart.texteMuted, fontSize: 12)),
      ],
    );
  }
}

class _Commandes extends StatelessWidget {
  const _Commandes({
    required this.store,
    required this.commandes,
    this.pourVendeur = false,
  });

  final MarketplaceStore store;
  final List<Commande> commandes;
  final bool pourVendeur;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (commandes.isEmpty) const ListeVide('Aucune commande pour le moment.'),
        for (var i = 0; i < commandes.length; i++)
          Apparition(
            key: ValueKey(commandes[i].id),
            index: i,
            child: CommandeTuile(store: store, commande: commandes[i], pourVendeur: pourVendeur),
          ),
      ],
    );
  }
}
