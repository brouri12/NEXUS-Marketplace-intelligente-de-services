import 'package:flutter/material.dart';

import 'package:flutter_android_app/core/theme/indigo_or_chart.dart';
import 'package:flutter_android_app/core/ui/nexus_ui.dart';
import 'package:flutter_android_app/gestions/marketplace/back/marketplace_store.dart';
import 'package:flutter_android_app/gestions/marketplace/back/produit.dart';

/// Ajout ou modification d'un produit par son vendeur.
class ProduitFormPage extends StatefulWidget {
  /// Ajoute un produit, ou modifie [produit].
  const ProduitFormPage({super.key, required this.store, this.produit});

  /// Boutique.
  final MarketplaceStore store;

  /// Produit modifié, absent pour un ajout.
  final Produit? produit;

  @override
  State<ProduitFormPage> createState() => _ProduitFormPageState();
}

class _ProduitFormPageState extends State<ProduitFormPage> {
  late final _nom = TextEditingController(text: widget.produit?.nom ?? '');
  late final _description = TextEditingController(text: widget.produit?.description ?? '');
  late final _prix = TextEditingController(
    text: widget.produit == null ? '' : _nombre(widget.produit!.prixDt),
  );
  late final _stock = TextEditingController(text: widget.produit?.stock.toString() ?? '');
  late final _unite = TextEditingController(text: widget.produit?.unite ?? 'pièce');
  late CategorieProduit _categorie =
      widget.produit?.categorie ?? CategorieProduit.demenagement;
  var _erreur = '';

  static String _nombre(double valeur) {
    return valeur == valeur.roundToDouble()
        ? valeur.toStringAsFixed(0)
        : valeur.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    _prix.dispose();
    _stock.dispose();
    _unite.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final edition = widget.produit != null;
    return Scaffold(
      appBar: AppBar(title: Text(edition ? 'Modifier le produit' : 'Nouveau produit')),
      backgroundColor: IndigoOrChart.fond,
      bottomNavigationBar: BarreAction(
        label: edition ? 'Enregistrer' : 'Mettre en vente',
        icone: edition ? Icons.check : Icons.storefront_outlined,
        onPressed: _enregistrer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('produit-nom'),
            controller: _nom,
            decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CategorieProduit>(
            initialValue: _categorie,
            decoration: const InputDecoration(
              labelText: 'Catégorie',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final categorie in CategorieProduit.values)
                DropdownMenuItem(value: categorie, child: Text(labelCategorie(categorie))),
            ],
            onChanged: (value) => setState(() => _categorie = value ?? _categorie),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('produit-prix'),
                  controller: _prix,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Prix (DT)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  key: const Key('produit-stock'),
                  controller: _stock,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _unite,
            decoration: const InputDecoration(
              labelText: 'Unité vendue',
              hintText: 'pièce, lot de 10, rouleau de 100 m…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_erreur.isNotEmpty)
            Text(_erreur, style: const TextStyle(color: IndigoOrChart.erreur)),
        ],
      ),
    );
  }

  void _enregistrer() {
    final store = widget.store;
    final produit = widget.produit;
    final erreur = produit == null
        ? store.ajouterProduit(
            nom: _nom.text,
            description: _description.text,
            categorie: _categorie,
            prix: _prix.text,
            stock: _stock.text,
            unite: _unite.text,
          )
        : store.modifierProduit(
            produit.id,
            nom: _nom.text,
            description: _description.text,
            categorie: _categorie,
            prix: _prix.text,
            stock: _stock.text,
            unite: _unite.text,
          );
    if (erreur != null) {
      setState(() => _erreur = erreur);
      return;
    }
    Navigator.of(context).pop();
  }
}
