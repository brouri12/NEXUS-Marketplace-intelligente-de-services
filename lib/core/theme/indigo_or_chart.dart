import 'package:flutter/material.dart';

/// Charte Indigo et or de NEXUS.
///
/// L'indigo porte la marque, les barres et les contrats.
/// L'or est réservé aux actions et aux mises en avant.
/// Les statuts restent à part, pour ne pas se confondre avec l'or.
abstract final class IndigoOrChart {
  /// Fond des écrans.
  static const fond = Color(0xFFF4F2EC);

  /// Surface des cartes, un ton au-dessus du fond.
  static const surface = Color(0xFFFFFCF7);

  /// Surface la plus haute, pour un champ ou une feuille.
  static const surfaceHaute = Color(0xFFFFFFFF);

  /// Indigo de la marque.
  static const primaire = Color(0xFF24315C);

  /// Texte et icônes posés sur [primaire].
  static const onPrimaire = Color(0xFFF4F2EC);

  /// Indigo éclairci, pour un bloc secondaire dans une barre.
  static const primaireConteneur = Color(0xFFD9DEEE);

  /// Texte posé sur [primaireConteneur].
  static const onPrimaireConteneur = Color(0xFF10182E);

  /// Indigo plus doux, pour un libellé ou une icône secondaire.
  static const secondaire = Color(0xFF4E5E8A);

  /// Texte et icônes posés sur [secondaire].
  static const onSecondaire = Color(0xFFF4F2EC);

  /// Fond d'un bloc secondaire.
  static const secondaireConteneur = Color(0xFFD9E0F0);

  /// Texte posé sur [secondaireConteneur].
  static const onSecondaireConteneur = Color(0xFF1A2444);

  /// Or des boutons et des prix mis en avant.
  static const or = Color(0xFFC4922A);

  /// Texte posé sur [or].
  static const onOr = Color(0xFF1C1408);

  /// Or assombri, lisible en petit sur le fond clair.
  static const orTexte = Color(0xFF8A6414);

  /// Fond d'un bloc or, pour une pastille ou une sélection.
  static const orConteneur = Color(0xFFF6E7C4);

  /// Texte posé sur [orConteneur].
  static const onOrConteneur = Color(0xFF3D2A08);

  /// Texte principal.
  static const texte = Color(0xFF161A24);

  /// Texte secondaire et légendes.
  static const texteMuted = Color(0xFF5C6578);

  /// Filet entre deux zones.
  static const contour = Color(0xFFC9C3B6);

  /// Filet plus léger, à l'intérieur d'une carte.
  static const contourDiscret = Color(0xFFE4DDD0);

  /// Succès. Distinct de l'or.
  static const succes = Color(0xFF1B6B45);

  /// Texte posé sur [succes].
  static const onSucces = Color(0xFFF4FBF7);

  /// Attente. Distinct de l'or des boutons.
  static const attente = Color(0xFF8A5A12);

  /// Texte posé sur [attente].
  static const onAttente = Color(0xFFFFF8EF);

  /// Erreur et réclamation.
  static const erreur = Color(0xFF9B2C2C);

  /// Texte posé sur [erreur].
  static const onErreur = Color(0xFFFFF7F5);

  /// Fond d'un message d'erreur.
  static const erreurConteneur = Color(0xFFF8D9D4);

  /// Texte posé sur [erreurConteneur].
  static const onErreurConteneur = Color(0xFF3F0A08);

  /// Schéma Material construit avec cette charte.
  static const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaire,
    onPrimary: onPrimaire,
    primaryContainer: primaireConteneur,
    onPrimaryContainer: onPrimaireConteneur,
    secondary: secondaire,
    onSecondary: onSecondaire,
    secondaryContainer: secondaireConteneur,
    onSecondaryContainer: onSecondaireConteneur,
    tertiary: or,
    onTertiary: onOr,
    tertiaryContainer: orConteneur,
    onTertiaryContainer: onOrConteneur,
    error: erreur,
    onError: onErreur,
    errorContainer: erreurConteneur,
    onErrorContainer: onErreurConteneur,
    surface: surface,
    onSurface: texte,
    onSurfaceVariant: texteMuted,
    outline: contour,
    outlineVariant: contourDiscret,
    shadow: texte,
    scrim: texte,
    inverseSurface: primaire,
    onInverseSurface: fond,
    inversePrimary: Color(0xFFB7C2E4),
    surfaceTint: primaire,
  );

  /// Thème clair NEXUS, Indigo et or.
  static ThemeData get theme {
    final scheme = colorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: fond,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaire,
        foregroundColor: onPrimaire,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceHaute,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: contourDiscret),
        ),
      ),
      dividerTheme: const DividerThemeData(color: contourDiscret, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: or,
          foregroundColor: onOr,
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: texte),
        bodyLarge: TextStyle(color: texte),
        titleMedium: TextStyle(color: texte),
        titleLarge: TextStyle(color: texte),
      ),
      iconTheme: const IconThemeData(color: secondaire),
    );
  }
}
