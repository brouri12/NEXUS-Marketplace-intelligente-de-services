/// Option choisie par le client, avec son prix en dinars.
class OptionLigne {
  /// Crée une ligne déjà chiffrée.
  const OptionLigne({required this.label, required this.prix});

  /// Nom affiché, par exemple « Camion ».
  final String label;

  /// Prix ajouté au devis, en dinars.
  final int prix;
}

/// Prix de base connu pour un métier.
int prixBaseService(String service) {
  return switch (service) {
    'Déménagement' => 100,
    'Plomberie' => 50,
    'Ménage' => 40,
    'Électricité' => 55,
    'Peinture' => 45,
    _ => 50,
  };
}

/// Prix connu d'une prestation déjà proposée.
int prixConnu(String label) {
  return switch (label) {
    'Camion' => 40,
    '3 personnes' => 60,
    'Emballage' => 30,
    'Montage' => 25,
    'Manutention' => 30,
    'Fuite' => 25,
    'Installation' => 35,
    'Débouchage' => 30,
    'Maison' => 20,
    'Bureau' => 25,
    'Vitres' => 15,
    'Dépannage' => 30,
    'Tableau' => 40,
    'Intérieur' => 35,
    'Extérieur' => 40,
    'Façade' => 45,
    _ => 20,
  };
}

/// Somme des options.
int prixOptions(List<OptionLigne> options) {
  return options.fold(0, (somme, option) => somme + option.prix);
}

/// Frais de déplacement : distance × prix au kilomètre.
int fraisDistance(double distanceKm, int prixParKm) {
  return (distanceKm * prixParKm).round();
}

/// Total : base + options + déplacement.
int prixTotal({
  required int prixBase,
  required List<OptionLigne> options,
  required double distanceKm,
  required int prixParKm,
}) {
  return prixBase + prixOptions(options) + fraisDistance(distanceKm, prixParKm);
}

/// Mention affichée sous chaque devis.
const remarqueDevis =
    'Ce devis est établi selon les informations fournies par le client. '
    'Il peut être modifié si les conditions réelles de la prestation changent. '
    'Toute modification doit être proposée au client et acceptée avant son application.';
