import '../domain/trajet.dart';

class LogistiqueApi {
  const LogistiqueApi();

  // Données factices pour tester l'interface de Listes et Layouts
  List<Trajet> get trajetsMock => [
    const Trajet(
      id: 'TRJ-001',
      pointDepart: 'Entrepôt A',
      destination: 'Client (Paris)',
      livreurNom: 'Jean Dupont',
      status: TrajetStatus.enCours,
      eta: '14:30',
    ),
    const Trajet(
      id: 'TRJ-002',
      pointDepart: 'Boutique Centre',
      destination: 'Client (Lyon)',
      livreurNom: 'Marie Curie',
      status: TrajetStatus.enRetard,
      eta: '16:45',
    ),
  ];
}
