import 'package:flutter/material.dart';

/// Catégorie de produits, alignée sur les secteurs de services.
enum CategorieProduit { demenagement, batiment, maison, electricite }

/// Libellé de [categorie].
String labelCategorie(CategorieProduit categorie) {
  return switch (categorie) {
    CategorieProduit.demenagement => 'Déménagement',
    CategorieProduit.batiment => 'Bâtiment',
    CategorieProduit.maison => 'Maison & jardin',
    CategorieProduit.electricite => 'Électricité',
  };
}

/// Icône de [categorie].
IconData iconeCategorie(CategorieProduit categorie) {
  return switch (categorie) {
    CategorieProduit.demenagement => Icons.local_shipping_outlined,
    CategorieProduit.batiment => Icons.construction_outlined,
    CategorieProduit.maison => Icons.yard_outlined,
    CategorieProduit.electricite => Icons.electrical_services_outlined,
  };
}

/// Produit vendu sur la marketplace : matériel et fournitures des services.
class Produit {
  /// Crée un produit.
  const Produit({
    required this.id,
    required this.vendeurId,
    required this.nom,
    required this.description,
    required this.categorie,
    required this.prixDt,
    required this.stock,
    required this.unite,
    required this.creeLe,
    this.actif = true,
  });

  /// Identifiant stable.
  final String id;

  /// Compte qui vend : un prestataire ou l'admin.
  final String vendeurId;

  /// Nom affiché.
  final String nom;

  /// Description courte.
  final String description;

  /// Catégorie du catalogue.
  final CategorieProduit categorie;

  /// Prix unitaire en dinars.
  final double prixDt;

  /// Quantité disponible.
  final int stock;

  /// Unité vendue, par exemple « pièce » ou « rouleau de 100 m ».
  final String unite;

  /// Moment de mise en vente.
  final DateTime creeLe;

  /// Faux quand le vendeur l'a retiré du catalogue.
  final bool actif;

  /// Whether the product can still be ordered.
  bool get disponible => actif && stock > 0;

  /// Copie avec les champs remplacés.
  Produit copyWith({
    String? nom,
    String? description,
    CategorieProduit? categorie,
    double? prixDt,
    int? stock,
    String? unite,
    bool? actif,
  }) {
    return Produit(
      id: id,
      vendeurId: vendeurId,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      categorie: categorie ?? this.categorie,
      prixDt: prixDt ?? this.prixDt,
      stock: stock ?? this.stock,
      unite: unite ?? this.unite,
      creeLe: creeLe,
      actif: actif ?? this.actif,
    );
  }
}

/// Avancement d'une commande.
enum StatutCommande { enAttente, confirmee, expediee, livree, annulee }

/// Libellé de [statut].
String labelStatutCommande(StatutCommande statut) {
  return switch (statut) {
    StatutCommande.enAttente => 'EN ATTENTE',
    StatutCommande.confirmee => 'CONFIRMÉE',
    StatutCommande.expediee => 'EXPÉDIÉE',
    StatutCommande.livree => 'LIVRÉE',
    StatutCommande.annulee => 'ANNULÉE',
  };
}

/// Produit commandé, figé au prix du moment.
class LigneCommande {
  /// Crée une ligne.
  const LigneCommande({
    required this.produitId,
    required this.nom,
    required this.prixDt,
    required this.quantite,
  });

  /// Lit une ligne stockée en JSON.
  factory LigneCommande.depuisJson(Map<String, Object?> json) => LigneCommande(
    produitId: json['produitId']! as String,
    nom: json['nom']! as String,
    prixDt: (json['prixDt']! as num).toDouble(),
    quantite: json['quantite']! as int,
  );

  /// Produit commandé.
  final String produitId;

  /// Nom au moment de la commande.
  final String nom;

  /// Prix unitaire au moment de la commande.
  final double prixDt;

  /// Quantité commandée.
  final int quantite;

  /// Prix de la ligne.
  double get total => prixDt * quantite;

  /// Ligne en JSON.
  Map<String, Object?> versJson() => {
    'produitId': produitId,
    'nom': nom,
    'prixDt': prixDt,
    'quantite': quantite,
  };
}

/// Commande passée à un vendeur.
class Commande {
  /// Crée une commande.
  const Commande({
    required this.id,
    required this.numero,
    required this.clientId,
    required this.vendeurId,
    required this.lignes,
    required this.adresse,
    required this.statut,
    required this.creeLe,
  });

  /// Identifiant stable.
  final String id;

  /// Numéro lisible, par exemple CMD-004.
  final String numero;

  /// Acheteur.
  final String clientId;

  /// Vendeur de tous les produits de la commande.
  final String vendeurId;

  /// Produits commandés.
  final List<LigneCommande> lignes;

  /// Adresse de livraison.
  final String adresse;

  /// Avancement.
  final StatutCommande statut;

  /// Moment de la commande.
  final DateTime creeLe;

  /// Montant total.
  double get total => lignes.fold(0, (somme, ligne) => somme + ligne.total);

  /// Nombre d'articles.
  int get articles => lignes.fold(0, (somme, ligne) => somme + ligne.quantite);

  /// Copie avec un nouveau statut.
  Commande avecStatut(StatutCommande suivant) => Commande(
    id: id,
    numero: numero,
    clientId: clientId,
    vendeurId: vendeurId,
    lignes: lignes,
    adresse: adresse,
    statut: suivant,
    creeLe: creeLe,
  );
}

/// Prix en dinars, sans décimales quand il est rond.
String formatPrix(double prix) {
  final texte = prix == prix.roundToDouble()
      ? prix.toStringAsFixed(0)
      : prix.toStringAsFixed(2);
  return '${texte.replaceAll('.', ',')} DT';
}
