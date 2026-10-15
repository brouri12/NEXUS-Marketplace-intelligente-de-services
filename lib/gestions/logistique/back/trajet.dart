/// État d'un trajet.
enum TrajetStatus {
  /// Planifié, pas encore parti.
  enAttente,

  /// Le prestataire est en route.
  enCours,

  /// En route avec un retard signalé.
  enRetard,

  /// Arrivé à destination.
  termine,
}

/// Libellé de [statut].
String labelTrajetStatus(TrajetStatus statut) {
  return switch (statut) {
    TrajetStatus.enAttente => 'EN ATTENTE',
    TrajetStatus.enCours => 'EN COURS',
    TrajetStatus.enRetard => 'EN RETARD',
    TrajetStatus.termine => 'TERMINÉ',
  };
}

/// Vitesse moyenne retenue en ville, en km/h.
const vitesseMoyenneKmH = 35;

/// Temps fixe de chargement et de stationnement, en minutes.
const margeMinutes = 10;

/// Durée estimée pour [distanceKm], en minutes.
int dureeEstimeeMinutes(double distanceKm) {
  return (distanceKm / vitesseMoyenneKmH * 60).round() + margeMinutes;
}

/// Trajet du prestataire vers le lieu d'un contrat.
class Trajet {
  /// Crée un trajet complet.
  const Trajet({
    required this.id,
    required this.numero,
    required this.contratId,
    required this.clientId,
    required this.prestataireId,
    required this.pointDepart,
    required this.destination,
    required this.distanceKm,
    required this.departPrevu,
    required this.status,
    required this.creeLe,
    this.departReel,
    this.arriveeReelle,
    this.retardMinutes = 0,
    this.note = '',
  });

  /// Identifiant stable.
  final String id;

  /// Numéro affiché, par exemple TRJ-001.
  final String numero;

  /// Contrat servi par ce trajet.
  final String contratId;

  /// Client qui attend.
  final String clientId;

  /// Prestataire qui conduit.
  final String prestataireId;

  /// Adresse de départ.
  final String pointDepart;

  /// Adresse d'arrivée.
  final String destination;

  /// Distance de l'itinéraire, en kilomètres.
  final double distanceKm;

  /// Départ planifié.
  final DateTime departPrevu;

  /// État actuel.
  final TrajetStatus status;

  /// Moment de création.
  final DateTime creeLe;

  /// Départ réel, une fois en route.
  final DateTime? departReel;

  /// Arrivée réelle, une fois terminé.
  final DateTime? arriveeReelle;

  /// Retard signalé, en minutes.
  final int retardMinutes;

  /// Motif du retard ou remarque du prestataire.
  final String note;

  /// Arrivée estimée : départ, durée de l'itinéraire, puis retard signalé.
  DateTime get eta {
    final depart = departReel ?? departPrevu;
    return depart.add(
      Duration(minutes: dureeEstimeeMinutes(distanceKm) + retardMinutes),
    );
  }

  /// Whether the trajet is still on the road or planned.
  bool get actif => status != TrajetStatus.termine;

  /// Copie avec les champs de suivi remplacés.
  Trajet copyWith({
    String? pointDepart,
    String? destination,
    double? distanceKm,
    DateTime? departPrevu,
    TrajetStatus? status,
    DateTime? departReel,
    DateTime? arriveeReelle,
    int? retardMinutes,
    String? note,
  }) {
    return Trajet(
      id: id,
      numero: numero,
      contratId: contratId,
      clientId: clientId,
      prestataireId: prestataireId,
      pointDepart: pointDepart ?? this.pointDepart,
      destination: destination ?? this.destination,
      distanceKm: distanceKm ?? this.distanceKm,
      departPrevu: departPrevu ?? this.departPrevu,
      status: status ?? this.status,
      creeLe: creeLe,
      departReel: departReel ?? this.departReel,
      arriveeReelle: arriveeReelle ?? this.arriveeReelle,
      retardMinutes: retardMinutes ?? this.retardMinutes,
      note: note ?? this.note,
    );
  }
}
