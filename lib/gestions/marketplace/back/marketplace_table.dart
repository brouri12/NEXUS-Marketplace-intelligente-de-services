import 'package:flutter_android_app/core/db/nexus_database.dart';
import 'package:flutter_android_app/gestions/marketplace/back/produit.dart';

/// Table des produits.
const tableProduits = 'produits';

/// Table des commandes.
const tableCommandes = 'commandes';

/// Schéma de la marketplace.
const schemaMarketplace = [
  '''
CREATE TABLE IF NOT EXISTS $tableProduits (
  id TEXT PRIMARY KEY,
  vendeur_id TEXT NOT NULL,
  nom TEXT NOT NULL,
  description TEXT NOT NULL,
  categorie TEXT NOT NULL,
  prix REAL NOT NULL,
  stock INTEGER NOT NULL,
  unite TEXT NOT NULL,
  cree_le INTEGER NOT NULL,
  actif INTEGER NOT NULL
)''',
  '''
CREATE TABLE IF NOT EXISTS $tableCommandes (
  id TEXT PRIMARY KEY,
  numero TEXT NOT NULL,
  client_id TEXT NOT NULL,
  vendeur_id TEXT NOT NULL,
  lignes TEXT NOT NULL,
  adresse TEXT NOT NULL,
  statut TEXT NOT NULL,
  cree_le INTEGER NOT NULL
)''',
];

/// Ligne SQLite de [produit].
Map<String, Object?> ligneProduit(Produit produit) => {
  'id': produit.id,
  'vendeur_id': produit.vendeurId,
  'nom': produit.nom,
  'description': produit.description,
  'categorie': produit.categorie.name,
  'prix': produit.prixDt,
  'stock': produit.stock,
  'unite': produit.unite,
  'cree_le': sqlDate(produit.creeLe),
  'actif': sqlBool(produit.actif),
};

/// Produit lu depuis [ligne].
Produit produitDepuis(Map<String, Object?> ligne) => Produit(
  id: ligne['id']! as String,
  vendeurId: lireTexte(ligne['vendeur_id']),
  nom: lireTexte(ligne['nom']),
  description: lireTexte(ligne['description']),
  categorie: CategorieProduit.values.byName(ligne['categorie']! as String),
  prixDt: (ligne['prix']! as num).toDouble(),
  stock: ligne['stock']! as int,
  unite: lireTexte(ligne['unite']),
  creeLe: lireDate(ligne['cree_le']),
  actif: lireBool(ligne['actif']),
);

/// Ligne SQLite de [commande].
Map<String, Object?> ligneCommande(Commande commande) => {
  'id': commande.id,
  'numero': commande.numero,
  'client_id': commande.clientId,
  'vendeur_id': commande.vendeurId,
  'lignes': sqlJson([for (final ligne in commande.lignes) ligne.versJson()]),
  'adresse': commande.adresse,
  'statut': commande.statut.name,
  'cree_le': sqlDate(commande.creeLe),
};

/// Commande lue depuis [ligne].
Commande commandeDepuis(Map<String, Object?> ligne) => Commande(
  id: ligne['id']! as String,
  numero: lireTexte(ligne['numero']),
  clientId: lireTexte(ligne['client_id']),
  vendeurId: lireTexte(ligne['vendeur_id']),
  lignes: [
    for (final item in (lireJson(ligne['lignes']) as List<Object?>? ?? const []))
      LigneCommande.depuisJson((item! as Map).cast<String, Object?>()),
  ],
  adresse: lireTexte(ligne['adresse']),
  statut: StatutCommande.values.byName(ligne['statut']! as String),
  creeLe: lireDate(ligne['cree_le']),
);
