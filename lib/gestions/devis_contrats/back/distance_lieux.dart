import 'dart:math' as math;

/// Distance retenue entre l'emplacement du prestataire et le lieu demandé.
class DistanceCalculee {
  /// Crée une distance déjà arrondie.
  const DistanceCalculee({required this.km, required this.reconnue});

  /// Kilomètres utilisés pour le devis.
  final double km;

  /// Whether both places matched a localité connue.
  final bool reconnue;

  /// Mention affichée à côté du kilométrage.
  String get mention => reconnue ? 'calculée automatiquement' : 'estimation';
}

/// Distance par défaut quand le lieu n'est pas reconnu.
const double distanceEstimeeKm = 8;

/// Distance locale quand les deux lieux se confondent.
const double distanceLocaleKm = 2;

/// Calcule la distance entre [emplacementPrestataire] et [lieuDemande].
DistanceCalculee distanceEntre({
  required String emplacementPrestataire,
  required String lieuDemande,
}) {
  final origine = _point(emplacementPrestataire);
  final destination = _point(lieuDemande);
  if (origine == null || destination == null) {
    final memeTexte = _cle(emplacementPrestataire).isNotEmpty &&
        _cle(emplacementPrestataire) == _cle(lieuDemande);
    return DistanceCalculee(
      km: memeTexte ? distanceLocaleKm : distanceEstimeeKm,
      reconnue: false,
    );
  }
  final km = _haversine(origine.$1, origine.$2, destination.$1, destination.$2);
  final retenue = km < 1.5 ? distanceLocaleKm : (km * 10).round() / 10;
  return DistanceCalculee(km: retenue, reconnue: true);
}

/// Coordonnées approximatives des lieux utilisés au Grand Tunis et en Tunisie.
const _coords = <String, (double, double)>{
  'tunis': (36.8065, 10.1815),
  'grand tunis': (36.8065, 10.1815),
  'la marsa': (36.8782, 10.3247),
  'marsa': (36.8782, 10.3247),
  'carthage': (36.8528, 10.3236),
  'sidi bou said': (36.8689, 10.3414),
  'ariana': (36.8625, 10.1956),
  'la soukra': (36.8831, 10.2500),
  'soukra': (36.8831, 10.2500),
  'gammarth': (36.9167, 10.2889),
  'la goulette': (36.8183, 10.3050),
  'le kram': (36.8378, 10.3167),
  'les berges du lac': (36.8350, 10.2410),
  'berges du lac': (36.8350, 10.2410),
  'centre urbain nord': (36.8500, 10.1950),
  'el menzah': (36.8380, 10.1750),
  'menzah': (36.8380, 10.1750),
  'charguia': (36.8410, 10.2050),
  'ben arous': (36.7531, 10.2189),
  'rades': (36.7681, 10.2753),
  'megrine': (36.7694, 10.2361),
  'ezzahra': (36.7447, 10.3083),
  'hammam lif': (36.7286, 10.3417),
  'manouba': (36.8081, 10.0972),
  'nabeul': (36.4513, 10.7357),
  'hammamet': (36.4000, 10.6167),
  'bizerte': (37.2744, 9.8739),
  'sousse': (35.8254, 10.6360),
  'monastir': (35.7643, 10.8113),
  'mahdia': (35.5047, 11.0622),
  'sfax': (34.7398, 10.7600),
  'kairouan': (35.6781, 10.0963),
  'gabes': (33.8815, 10.0982),
  'djerba': (33.8076, 10.8451),
  'zaghouan': (36.4029, 10.1429),
};

(double, double)? _point(String lieu) {
  final cle = _cle(lieu);
  if (cle.isEmpty) return null;
  String? meilleur;
  for (final key in _coords.keys) {
    if (cle == key || cle.contains(key)) {
      if (meilleur == null || key.length > meilleur.length) meilleur = key;
    }
  }
  return meilleur == null ? null : _coords[meilleur];
}

String _cle(String value) {
  const accents = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'ï': 'i',
    'î': 'i',
    'ô': 'o',
    'ö': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
  };
  final buffer = StringBuffer();
  for (final char in value.toLowerCase().split('')) {
    buffer.write(accents[char] ?? char);
  }
  return buffer.toString().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}

double _haversine(double lat1, double lng1, double lat2, double lng2) {
  const rayonTerreKm = 6371.0;
  double rad(double degre) => degre * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.sin(dLng / 2) * math.sin(dLng / 2);
  return rayonTerreKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}
