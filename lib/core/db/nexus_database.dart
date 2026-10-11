import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Base SQLite locale partagée par toutes les gestions.
///
/// Tant qu'elle n'est pas ouverte (tests, web, bureau), chaque écriture
/// est ignorée et les gestions restent en mémoire.
class NexusDatabase {
  NexusDatabase._();

  /// Instance unique de l'application.
  static final instance = NexusDatabase._();

  static const _nomFichier = 'nexus.db';
  static const _version = 1;
  static const _tableSemis = 'tables_semees';

  Database? _db;

  /// Whether the SQLite file is open.
  bool get ouverte => _db != null;

  /// Ouvre la base et crée les tables décrites par [schema].
  ///
  /// Les instructions doivent utiliser `CREATE TABLE IF NOT EXISTS` : elles
  /// sont rejouées à chaque ouverture pour ajouter les nouvelles tables.
  Future<void> ouvrir(List<String> schema) async {
    if (_db != null || !_plateformeSupportee) return;
    final dossier = await getDatabasesPath();
    Future<void> creer(Database db) async {
      final batch = db.batch()
        ..execute(
          'CREATE TABLE IF NOT EXISTS $_tableSemis (nom TEXT PRIMARY KEY)',
        );
      for (final sql in schema) {
        batch.execute(sql);
      }
      await batch.commit(noResult: true);
    }

    _db = await openDatabase(
      p.join(dossier, _nomFichier),
      version: _version,
      onCreate: (db, _) => creer(db),
      onOpen: creer,
    );
  }

  /// Ferme la base.
  Future<void> fermer() async {
    final db = _db;
    _db = null;
    await db?.close();
  }

  /// Lignes de [table], ou `null` si la gestion doit garder ses données.
  ///
  /// Au premier passage, [graines] sont écrites et `null` est retourné :
  /// la gestion garde alors ses données de démonstration déjà en mémoire.
  Future<List<Map<String, Object?>>?> charger(
    String table,
    Iterable<Map<String, Object?>> graines,
  ) async {
    final db = _db;
    if (db == null) return null;
    final semee = await db.query(
      _tableSemis,
      where: 'nom = ?',
      whereArgs: [table],
    );
    if (semee.isNotEmpty) return db.query(table);

    final batch = db.batch();
    for (final ligne in graines) {
      batch.insert(table, ligne, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    batch.insert(_tableSemis, {'nom': table});
    await batch.commit(noResult: true);
    return null;
  }

  /// Crée ou remplace la ligne [ligne] de [table].
  void enregistrer(String table, Map<String, Object?> ligne) {
    final db = _db;
    if (db == null) return;
    _lancer(db.insert(table, ligne, conflictAlgorithm: ConflictAlgorithm.replace));
  }

  /// Supprime la ligne [id] de [table].
  void supprimer(String table, String id) {
    final db = _db;
    if (db == null) return;
    _lancer(db.delete(table, where: 'id = ?', whereArgs: [id]));
  }

  void _lancer(Future<Object?> operation) {
    unawaited(
      operation.then<void>(
        (_) {},
        onError: (Object error, StackTrace stack) {
          debugPrint('SQLite : $error');
        },
      ),
    );
  }

  bool get _plateformeSupportee {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };
  }
}

/// Base partagée.
NexusDatabase get nexusDb => NexusDatabase.instance;

/// Booléen stocké en entier.
int sqlBool(bool value) => value ? 1 : 0;

/// Entier lu comme booléen.
bool lireBool(Object? value) => value == 1;

/// Date stockée en millisecondes.
int? sqlDate(DateTime? value) => value?.millisecondsSinceEpoch;

/// Millisecondes lues comme date.
DateTime lireDate(Object? value) {
  return DateTime.fromMillisecondsSinceEpoch((value as int?) ?? 0);
}

/// Millisecondes lues comme date facultative.
DateTime? lireDateOuNull(Object? value) {
  if (value == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(value as int);
}

/// Texte lu, vide si absent.
String lireTexte(Object? value) => (value as String?) ?? '';

/// Liste de textes stockée en JSON.
String sqlListe(List<String> values) => jsonEncode(values);

/// JSON lu comme liste de textes.
List<String> lireListe(Object? value) {
  final raw = value as String?;
  if (raw == null || raw.isEmpty) return const [];
  return [for (final item in jsonDecode(raw) as List<Object?>) '$item'];
}

/// Valeur stockée en JSON.
String sqlJson(Object? value) => jsonEncode(value);

/// JSON lu, `null` si absent.
Object? lireJson(Object? value) {
  final raw = value as String?;
  if (raw == null || raw.isEmpty) return null;
  return jsonDecode(raw);
}

/// Plus grand suffixe numérique des identifiants `prefixe-N`, plus un.
int prochainNumero(Iterable<String> ids, String prefixe, int minimum) {
  var suivant = minimum;
  for (final id in ids) {
    if (!id.startsWith(prefixe)) continue;
    final numero = int.tryParse(id.substring(prefixe.length));
    if (numero != null && numero >= suivant) suivant = numero + 1;
  }
  return suivant;
}
