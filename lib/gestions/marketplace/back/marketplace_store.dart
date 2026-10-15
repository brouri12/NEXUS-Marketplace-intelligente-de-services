import 'package:flutter/foundation.dart';

import 'package:flutter_android_app/core/db/nexus_database.dart';
import 'package:flutter_android_app/gestions/marketplace/back/marketplace_table.dart';
import 'package:flutter_android_app/gestions/marketplace/back/produit.dart';
import 'package:flutter_android_app/gestions/utilisateurs/back/user_account.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

/// Produits des services, panier et commandes.
class MarketplaceStore extends ChangeNotifier {
  /// Pose le catalogue et les commandes de démonstration.
  MarketplaceStore() {
    final mise = DateTime(2026, 9, 1);
    Produit p(
      String id,
      String vendeur,
      CategorieProduit categorie,
      String nom,
      String description,
      double prix,
      int stock,
      String unite,
    ) {
      return Produit(
        id: id,
        vendeurId: vendeur,
        nom: nom,
        description: description,
        categorie: categorie,
        prixDt: prix,
        stock: stock,
        unite: unite,
        creeLe: mise,
      );
    }

    const dem = CategorieProduit.demenagement;
    const bat = CategorieProduit.batiment;
    const mai = CategorieProduit.maison;
    const ele = CategorieProduit.electricite;
    _produits = [
      p('prd-1', 'u-provider', dem, 'Cartons de déménagement', 'Cartons double cannelure 60 × 40 × 40 cm.', 25, 40, 'lot de 10'),
      p('prd-2', 'u-admin', dem, 'Palette bois 80 × 120', 'Palette EUR traitée, charge 1 500 kg.', 18, 30, 'pièce'),
      p('prd-3', 'u-provider', dem, 'Sangles d\'arrimage', 'Sangles à cliquet 5 m, 800 kg.', 35, 20, 'lot de 4'),
      p('prd-4', 'u-admin', dem, 'Diable de manutention', 'Diable acier, roues gonflables, 250 kg.', 120, 8, 'pièce'),
      p('prd-5', 'u-admin', dem, 'Papier bulle', 'Film de protection pour la vaisselle et les meubles.', 22, 25, 'rouleau de 50 m'),
      p('prd-6', 'u-batiment', bat, 'Peinture acrylique blanche', 'Peinture mate intérieure, lessivable.', 95, 15, 'pot de 10 L'),
      p('prd-7', 'u-batiment', bat, 'Rouleau et bac à peinture', 'Rouleau 180 mm, manchon microfibre.', 15, 30, 'kit'),
      p('prd-8', 'u-batiment', bat, 'Robinet mitigeur', 'Mitigeur évier chromé, bec orientable.', 65, 12, 'pièce'),
      p('prd-9', 'u-admin', bat, 'Tube PER 16 mm', 'Tube gainé pour eau chaude et froide.', 48, 18, 'couronne de 25 m'),
      p('prd-10', 'u-maison', mai, 'Râteau à feuilles', 'Râteau éventail 22 dents, manche bois.', 19, 25, 'pièce'),
      p('prd-11', 'u-maison', mai, 'Sécateur', 'Sécateur de jardin, lames acier.', 28, 20, 'pièce'),
      p('prd-12', 'u-maison', mai, 'Tuyau d\'arrosage', 'Tuyau anti-torsion avec raccords.', 42, 14, 'rouleau de 20 m'),
      p('prd-13', 'u-admin', mai, 'Kit de nettoyage', 'Seau, serpillière, raclette et microfibres.', 30, 22, 'kit'),
      p('prd-14', 'u-electricite', ele, 'Câble électrique 2,5 mm²', 'Câble rigide H07V-U pour prises.', 145, 10, 'rouleau de 100 m'),
      p('prd-15', 'u-electricite', ele, 'Disjoncteur 20 A', 'Disjoncteur modulaire phase + neutre.', 22, 35, 'pièce'),
      p('prd-16', 'u-electricite', ele, 'Prise murale 2P+T', 'Prise encastrable 16 A blanche.', 8.5, 60, 'pièce'),
      p('prd-17', 'u-admin', ele, 'Ampoules LED 9 W', 'Culot E27, blanc chaud.', 16, 40, 'lot de 4'),
    ];
    _commandes = [
      Commande(
        id: 'cmd-1',
        numero: 'CMD-001',
        clientId: 'u-client',
        vendeurId: 'u-provider',
        lignes: const [
          LigneCommande(produitId: 'prd-1', nom: 'Cartons de déménagement', prixDt: 25, quantite: 2),
          LigneCommande(produitId: 'prd-3', nom: 'Sangles d\'arrimage', prixDt: 35, quantite: 1),
        ],
        adresse: 'La Marsa',
        statut: StatutCommande.livree,
        creeLe: DateTime(2026, 9, 24, 11),
      ),
      Commande(
        id: 'cmd-2',
        numero: 'CMD-002',
        clientId: 'u-client',
        vendeurId: 'u-electricite',
        lignes: const [
          LigneCommande(produitId: 'prd-14', nom: 'Câble électrique 2,5 mm²', prixDt: 145, quantite: 1),
          LigneCommande(produitId: 'prd-16', nom: 'Prise murale 2P+T', prixDt: 8.5, quantite: 4),
        ],
        adresse: 'Tunis',
        statut: StatutCommande.enAttente,
        creeLe: DateTime(2026, 10, 9, 17),
      ),
    ];
    utilisateursStore.addListener(notifyListeners);
  }

  List<Produit> _produits = [];
  List<Commande> _commandes = [];
  final Map<String, Map<String, int>> _paniers = {};
  var _nextProduit = 18;
  var _nextCommande = 3;

  /// Recharge produits et commandes depuis SQLite.
  Future<void> charger() async {
    final produits = await nexusDb.charger(tableProduits, _produits.map(ligneProduit));
    final commandes = await nexusDb.charger(tableCommandes, _commandes.map(ligneCommande));
    if (produits != null) _produits = produits.map(produitDepuis).toList();
    if (commandes != null) _commandes = commandes.map(commandeDepuis).toList();
    _nextProduit = prochainNumero(_produits.map((item) => item.id), 'prd-', _nextProduit);
    _nextCommande = prochainNumero(_commandes.map((item) => item.id), 'cmd-', _nextCommande);
    notifyListeners();
  }

  // Droits.

  /// Compte ouvert.
  UserAccount? get session => utilisateursStore.current;

  /// Whether the open admin manages every product and order.
  bool get adminView =>
      session?.hasRole(UserRole.admin) == true && !utilisateursStore.clientInterface;

  /// Whether the open account sells its own products.
  bool get vendeurView => session?.hasRole(UserRole.provider) == true && !adminView;

  /// Whether the open account buys.
  bool get acheteurView => session?.hasRole(UserRole.client) == true && !adminView;

  /// Nom affiché du vendeur [id]. L'admin vend sous la marque NEXUS.
  String nomVendeur(String id) {
    final compte = utilisateursStore.find(id);
    if (compte == null) return 'Vendeur';
    if (compte.hasRole(UserRole.admin)) return 'NEXUS Shop';
    return compte.fullName;
  }

  /// Nom du compte [id].
  String nomDe(String id) => utilisateursStore.find(id)?.fullName ?? 'Compte';

  // Produits.

  /// Produits en vente, filtrés par [categorie] et par [recherche].
  List<Produit> catalogue({CategorieProduit? categorie, String recherche = ''}) {
    final mots = recherche.trim().toLowerCase();
    return [
      for (final produit in _produits)
        if (produit.actif &&
            (categorie == null || produit.categorie == categorie) &&
            (mots.isEmpty ||
                produit.nom.toLowerCase().contains(mots) ||
                produit.description.toLowerCase().contains(mots)))
          produit,
    ]..sort((a, b) {
      final parCategorie = a.categorie.index.compareTo(b.categorie.index);
      return parCategorie != 0 ? parCategorie : a.nom.compareTo(b.nom);
    });
  }

  /// Produit [id], ou `null`.
  Produit? find(String id) {
    for (final produit in _produits) {
      if (produit.id == id) return produit;
    }
    return null;
  }

  /// Produits du vendeur ouvert, ou tous pour l'admin.
  List<Produit> mesProduits() {
    final id = session?.id;
    if (id == null) return const [];
    return [
      for (final produit in _produits)
        if (adminView || (vendeurView && produit.vendeurId == id)) produit,
    ]..sort((a, b) => b.creeLe.compareTo(a.creeLe));
  }

  /// Whether the open account may edit [produit].
  bool peutGerer(Produit produit) {
    return adminView || (vendeurView && produit.vendeurId == session?.id);
  }

  /// Met un nouveau produit en vente.
  String? ajouterProduit({
    required String nom,
    required String description,
    required CategorieProduit categorie,
    required String prix,
    required String stock,
    required String unite,
  }) {
    final user = session;
    if (user == null || !(vendeurView || adminView)) {
      return 'Seul un prestataire ou un admin vend des produits.';
    }
    final lu = _lire(nom: nom, prix: prix, stock: stock, unite: unite);
    if (lu.$1 != null) return lu.$1;
    final produit = Produit(
      id: 'prd-${_nextProduit++}',
      vendeurId: user.id,
      nom: nom.trim(),
      description: description.trim(),
      categorie: categorie,
      prixDt: lu.$2!,
      stock: lu.$3!,
      unite: unite.trim(),
      creeLe: DateTime.now(),
    );
    _produits = [..._produits, produit];
    nexusDb.enregistrer(tableProduits, ligneProduit(produit));
    notifyListeners();
    return null;
  }

  /// Corrige un produit.
  String? modifierProduit(
    String id, {
    required String nom,
    required String description,
    required CategorieProduit categorie,
    required String prix,
    required String stock,
    required String unite,
  }) {
    final produit = find(id);
    if (produit == null) return 'Produit introuvable.';
    if (!peutGerer(produit)) return 'Ce produit ne vous appartient pas.';
    final lu = _lire(nom: nom, prix: prix, stock: stock, unite: unite);
    if (lu.$1 != null) return lu.$1;
    _remplacerProduit(
      produit.copyWith(
        nom: nom.trim(),
        description: description.trim(),
        categorie: categorie,
        prixDt: lu.$2,
        stock: lu.$3,
        unite: unite.trim(),
      ),
    );
    return null;
  }

  /// Retire un produit du catalogue, ou l'y remet.
  String? basculerVente(String id) {
    final produit = find(id);
    if (produit == null || !peutGerer(produit)) return 'Ce produit ne vous appartient pas.';
    _remplacerProduit(produit.copyWith(actif: !produit.actif));
    return null;
  }

  /// Supprime un produit. Les commandes passées gardent leur copie.
  String? supprimerProduit(String id) {
    final produit = find(id);
    if (produit == null) return 'Produit introuvable.';
    if (!peutGerer(produit)) return 'Ce produit ne vous appartient pas.';
    _produits = [for (final item in _produits) if (item.id != id) item];
    for (final panier in _paniers.values) {
      panier.remove(id);
    }
    nexusDb.supprimer(tableProduits, id);
    notifyListeners();
    return null;
  }

  // Panier.

  Map<String, int> get _panier => _paniers.putIfAbsent(session?.id ?? '', () => {});

  /// Produits du panier du compte ouvert, avec leur quantité.
  List<(Produit, int)> panier() {
    return [
      for (final entry in _panier.entries)
        if (find(entry.key) case final produit?) (produit, entry.value),
    ];
  }

  /// Quantité de [produitId] déjà dans le panier.
  int dansLePanier(String produitId) => _panier[produitId] ?? 0;

  /// Nombre d'articles du panier.
  int get articlesPanier => _panier.values.fold(0, (somme, quantite) => somme + quantite);

  /// Montant du panier.
  double get totalPanier {
    return panier().fold(0, (somme, item) => somme + item.$1.prixDt * item.$2);
  }

  /// Ajoute [quantite] de [produitId] au panier.
  String? ajouterAuPanier(String produitId, int quantite) {
    final produit = find(produitId);
    if (!acheteurView) return 'Connectez-vous avec un compte client pour acheter.';
    if (produit == null || !produit.disponible) return 'Ce produit n\'est plus disponible.';
    if (produit.vendeurId == session?.id) return 'Vous ne pouvez pas acheter votre propre produit.';
    if (quantite <= 0) return 'Choisissez une quantité.';
    final total = dansLePanier(produitId) + quantite;
    if (total > produit.stock) return 'Il ne reste que ${produit.stock} en stock.';
    _panier[produitId] = total;
    notifyListeners();
    return null;
  }

  /// Fixe la quantité de [produitId]. Zéro le retire.
  String? changerQuantite(String produitId, int quantite) {
    final produit = find(produitId);
    if (produit == null || quantite <= 0) {
      _panier.remove(produitId);
    } else if (quantite > produit.stock) {
      return 'Il ne reste que ${produit.stock} en stock.';
    } else {
      _panier[produitId] = quantite;
    }
    notifyListeners();
    return null;
  }

  /// Passe une commande par vendeur et retire les quantités du stock.
  String? commander(String adresse) {
    final user = session;
    if (user == null || !acheteurView) return 'Seul un client passe commande.';
    final items = panier();
    if (items.isEmpty) return 'Votre panier est vide.';
    if (adresse.trim().isEmpty) return 'Indiquez l\'adresse de livraison.';
    for (final (produit, quantite) in items) {
      if (!produit.disponible || quantite > produit.stock) {
        return 'Stock insuffisant pour « ${produit.nom} ».';
      }
    }
    final parVendeur = <String, List<(Produit, int)>>{};
    for (final item in items) {
      parVendeur.putIfAbsent(item.$1.vendeurId, () => []).add(item);
    }
    for (final entry in parVendeur.entries) {
      final numero = _nextCommande++;
      final commande = Commande(
        id: 'cmd-$numero',
        numero: 'CMD-${numero.toString().padLeft(3, '0')}',
        clientId: user.id,
        vendeurId: entry.key,
        lignes: [
          for (final (produit, quantite) in entry.value)
            LigneCommande(
              produitId: produit.id,
              nom: produit.nom,
              prixDt: produit.prixDt,
              quantite: quantite,
            ),
        ],
        adresse: adresse.trim(),
        statut: StatutCommande.enAttente,
        creeLe: DateTime.now(),
      );
      _commandes = [..._commandes, commande];
      nexusDb.enregistrer(tableCommandes, ligneCommande(commande));
      for (final (produit, quantite) in entry.value) {
        _remplacerProduit(produit.copyWith(stock: produit.stock - quantite), notifier: false);
      }
    }
    _panier.clear();
    notifyListeners();
    return null;
  }

  // Commandes.

  /// Commandes passées par le compte ouvert.
  List<Commande> mesCommandes() {
    final id = session?.id;
    if (id == null || !acheteurView) return const [];
    return _triees(_commandes.where((commande) => commande.clientId == id));
  }

  /// Commandes reçues par le vendeur ouvert.
  List<Commande> ventes() {
    final id = session?.id;
    if (id == null || !vendeurView) return const [];
    return _triees(_commandes.where((commande) => commande.vendeurId == id));
  }

  /// Toutes les commandes, pour l'admin.
  List<Commande> toutesLesCommandes() => adminView ? _triees(_commandes) : const [];

  /// Commande [id] si le compte ouvert peut la lire.
  Commande? findCommande(String id) {
    final moi = session?.id;
    for (final commande in _commandes) {
      if (commande.id != id) continue;
      if (adminView || commande.clientId == moi || commande.vendeurId == moi) return commande;
    }
    return null;
  }

  /// Whether the open account sells this [commande], or is admin.
  bool estVendeurDe(Commande commande) {
    return adminView || (vendeurView && commande.vendeurId == session?.id);
  }

  /// Étape suivante du vendeur, ou `null` si la commande est finie.
  StatutCommande? etapeSuivante(Commande commande) {
    return switch (commande.statut) {
      StatutCommande.enAttente => StatutCommande.confirmee,
      StatutCommande.confirmee => StatutCommande.expediee,
      StatutCommande.expediee => StatutCommande.livree,
      _ => null,
    };
  }

  /// Le vendeur fait avancer la commande d'une étape.
  String? avancer(String id) {
    final commande = findCommande(id);
    if (commande == null || !estVendeurDe(commande)) return 'Cette vente ne vous appartient pas.';
    final suivante = etapeSuivante(commande);
    if (suivante == null) return 'Cette commande est terminée.';
    _remplacerCommande(commande.avecStatut(suivante));
    return null;
  }

  /// Annule une commande et remet les produits en stock.
  ///
  /// Le client annule tant qu'elle attend, le vendeur tant qu'elle n'est pas livrée.
  String? annuler(String id) {
    final commande = findCommande(id);
    if (commande == null) return 'Commande introuvable.';
    final client = acheteurView && commande.clientId == session?.id;
    if (client && commande.statut != StatutCommande.enAttente && !estVendeurDe(commande)) {
      return 'Le vendeur a déjà confirmé cette commande.';
    }
    if (!client && !estVendeurDe(commande)) return 'Cette commande ne vous appartient pas.';
    if (commande.statut == StatutCommande.livree || commande.statut == StatutCommande.annulee) {
      return 'Cette commande ne peut plus être annulée.';
    }
    for (final ligne in commande.lignes) {
      final produit = find(ligne.produitId);
      if (produit != null) {
        _remplacerProduit(produit.copyWith(stock: produit.stock + ligne.quantite), notifier: false);
      }
    }
    _remplacerCommande(commande.avecStatut(StatutCommande.annulee));
    return null;
  }

  /// L'admin supprime une commande livrée ou annulée.
  String? supprimerCommande(String id) {
    final commande = findCommande(id);
    if (!adminView) return 'Seul un admin supprime une commande.';
    if (commande == null) return 'Commande introuvable.';
    if (commande.statut != StatutCommande.livree && commande.statut != StatutCommande.annulee) {
      return 'Seule une commande livrée ou annulée peut être supprimée.';
    }
    _commandes = [for (final item in _commandes) if (item.id != id) item];
    nexusDb.supprimer(tableCommandes, id);
    notifyListeners();
    return null;
  }

  /// Chiffre d'affaires livré du vendeur ouvert, ou de toute la plateforme.
  double get chiffreAffaires {
    final commandes = adminView ? _commandes : ventes();
    return commandes
        .where((commande) => commande.statut == StatutCommande.livree)
        .fold(0, (somme, commande) => somme + commande.total);
  }

  void _remplacerProduit(Produit next, {bool notifier = true}) {
    _produits = [for (final item in _produits) item.id == next.id ? next : item];
    nexusDb.enregistrer(tableProduits, ligneProduit(next));
    if (notifier) notifyListeners();
  }

  void _remplacerCommande(Commande next) {
    _commandes = [for (final item in _commandes) item.id == next.id ? next : item];
    nexusDb.enregistrer(tableCommandes, ligneCommande(next));
    notifyListeners();
  }

  List<Commande> _triees(Iterable<Commande> items) {
    return items.toList()..sort((a, b) => b.creeLe.compareTo(a.creeLe));
  }

  (String?, double?, int?) _lire({
    required String nom,
    required String prix,
    required String stock,
    required String unite,
  }) {
    if (nom.trim().length < 3) return ('Le nom du produit est obligatoire.', null, null);
    if (unite.trim().isEmpty) return ('Indiquez l\'unité vendue.', null, null);
    final montant = double.tryParse(prix.trim().replaceAll(',', '.'));
    if (montant == null || montant <= 0) return ('Le prix doit être positif.', null, null);
    final quantite = int.tryParse(stock.trim());
    if (quantite == null || quantite < 0) return ('Le stock est un nombre entier.', null, null);
    return (null, montant, quantite);
  }
}
