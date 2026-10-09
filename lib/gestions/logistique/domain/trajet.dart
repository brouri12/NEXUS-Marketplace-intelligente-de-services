enum TrajetStatus { enAttente, enCours, enRetard, termine }

class Trajet {
  final String id;
  final String pointDepart;
  final String destination;
  final String livreurNom;
  final TrajetStatus status;
  final String eta;

  const Trajet({
    required this.id,
    required this.pointDepart,
    required this.destination,
    required this.livreurNom,
    required this.status,
    required this.eta,
  });
}
