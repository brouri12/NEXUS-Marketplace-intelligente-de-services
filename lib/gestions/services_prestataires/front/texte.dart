import 'package:flutter_android_app/gestions/services_prestataires/front/modele.dart';

/// Libellé du profil déjà choisi sur le compte.
String libelleSecteur(SecteurCompte secteur) {
  return switch (secteur) {
    SecteurCompte.demenagement => 'Déménagement',
    SecteurCompte.batiment => 'Bâtiment',
    SecteurCompte.maison => 'Maison',
    SecteurCompte.electricite => 'Électricité',
  };
}

/// Secteur d'un métier déclaré sur le compte, déménagement par défaut.
SecteurCompte secteurDuMetier(String? metier) {
  final texte = (metier ?? '').trim().toLowerCase();
  for (final secteur in SecteurCompte.values) {
    if (servicesDuSecteur(secteur).any((service) => service.toLowerCase() == texte)) {
      return secteur;
    }
  }
  return SecteurCompte.demenagement;
}

/// Services qu'un compte de [secteur] peut ajouter.
List<String> servicesDuSecteur(SecteurCompte secteur) {
  return switch (secteur) {
    SecteurCompte.demenagement => const [
      'Déménagement',
      'Transport de meubles',
      'Garde-meuble',
    ],
    SecteurCompte.batiment => const [
      'Peinture',
      'Plomberie',
      'Menuiserie',
    ],
    SecteurCompte.maison => const [
      'Ménage',
      'Jardinage',
      'Climatisation',
    ],
    SecteurCompte.electricite => const [
      'Électricité',
      'Dépannage électrique',
      'Installation électrique',
    ],
  };
}

/// Pastilles connues du secteur.
List<String> competencesDuSecteur(SecteurCompte secteur) {
  return switch (secteur) {
    SecteurCompte.demenagement => const [
      'Conduite poids lourd',
      'Port de charges',
      'Emballage',
      'Montage de meubles',
    ],
    SecteurCompte.batiment => const [
      'Préparation des murs',
      'Recherche de fuite',
      'Finition',
      'Menuiserie',
    ],
    SecteurCompte.maison => const [
      'Entretien courant',
      'Tonte',
      'Entretien climatiseur',
    ],
    SecteurCompte.electricite => const [
      'Tableau électrique',
      'Éclairage',
      'Dépannage',
    ],
  };
}

/// Libellé d'un véhicule.
String libelleVehicule(VehiculeService vehicule) {
  return switch (vehicule) {
    VehiculeService.aucun => 'Aucun',
    VehiculeService.voiture => 'Voiture',
    VehiculeService.camion => 'Camion',
  };
}

/// Libellé d'un type de tarif.
String libelleTypeTarif(TypeTarif type) {
  return switch (type) {
    TypeTarif.heure => 'À l\'heure',
    TypeTarif.forfait => 'Au forfait',
    TypeTarif.camion => 'Au camion',
  };
}

/// Libellé d'un moment de journée.
String libelleMoment(MomentJournee moment) {
  return switch (moment) {
    MomentJournee.matin => 'Matin',
    MomentJournee.apresMidi => 'Après-midi',
    MomentJournee.soir => 'Soir',
  };
}

/// Jour ramené à minuit.
DateTime dateSeule(DateTime jour) {
  return DateTime(jour.year, jour.month, jour.day);
}

/// Lundi de la semaine qui contient [jour].
DateTime lundiDe(DateTime jour) {
  final date = dateSeule(jour);
  return date.subtract(Duration(days: date.weekday - DateTime.monday));
}

/// Nom du jour, avec une majuscule.
String nomJour(DateTime jour) {
  const noms = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
  return noms[jour.weekday - 1];
}

/// Nom court du jour, pour la bande de la semaine.
String nomJourCourt(DateTime jour) {
  const noms = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  return noms[jour.weekday - 1];
}

String _mois(DateTime jour) {
  const mois = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];
  return mois[jour.month - 1];
}

/// Titre de la semaine affichée.
String libelleSemaine(DateTime lundi) {
  final dimanche = lundi.add(const Duration(days: 6));
  if (lundi.month == dimanche.month) {
    return 'Semaine du ${lundi.day} au ${dimanche.day} ${_mois(lundi)}';
  }
  return 'Semaine du ${lundi.day} ${_mois(lundi)} au ${dimanche.day} ${_mois(dimanche)}';
}

/// Jour sélectionné, par exemple Vendredi 2 octobre.
String libelleJour(DateTime jour) {
  return '${nomJour(jour)} ${jour.day} ${_mois(jour)}';
}

/// Bloc en toutes lettres, par exemple Samedi matin.
String libelleCreneau(RefCreneau creneau, {bool majuscule = true}) {
  final jour = nomJour(creneau.jour);
  final moment = libelleMoment(creneau.moment).toLowerCase();
  final nom = majuscule ? jour : jour.toLowerCase();
  return '$nom $moment';
}

/// Trois premiers trous, puis le reste en nombre.
String resumeTrous(List<RefCreneau> trous) {
  if (trous.isEmpty) {
    return '';
  }
  final affiches = trous
      .take(3)
      .map((creneau) => libelleCreneau(creneau, majuscule: false))
      .join(', ');
  final reste = trous.length - 3;
  if (reste <= 0) {
    return affiches;
  }
  return '$affiches et $reste autres';
}
