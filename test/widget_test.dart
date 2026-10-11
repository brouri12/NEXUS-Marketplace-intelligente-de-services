import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_android_app/app/nexus_app.dart';

void main() {
  testWidgets('L accueil relie les cinq gestions', (WidgetTester tester) async {
    await tester.pumpWidget(const NexusApp());

    expect(find.text('NEXUS'), findsOneWidget);
    expect(find.text('Utilisateurs'), findsOneWidget);
    expect(find.text('Services & prestataires'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);
    expect(find.text('Devis et contrats'), findsOneWidget);
    expect(find.text('Communication & réclamation'), findsOneWidget);
  });

  testWidgets('La fiche et les ecrans services se parcourent', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NexusApp());
    await tester.tap(find.text('Services & prestataires'));
    await tester.pumpAndSettle();

    expect(find.text('Tableau de bord'), findsOneWidget);
    expect(find.text('1 en attente'), findsOneWidget);
    expect(find.text('Mes services'), findsOneWidget);
    expect(find.text('Compétences'), findsOneWidget);
    expect(find.text('Tarifs'), findsOneWidget);
    expect(find.text('Disponibilités'), findsOneWidget);

    await tester.tap(find.text('1 en attente'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Les demandes en attente s\'ouvrent dans la liste Demandes du prestataire.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fiche publique'));
    await tester.pumpAndSettle();
    expect(find.text('Aperçu client'), findsOneWidget);
    expect(find.text('Déménagement'), findsOneWidget);
    expect(find.text('Grand Tunis · 25 km'), findsOneWidget);
    expect(find.text('150 DT · au camion'), findsOneWidget);
    expect(find.text('Pas encore de note.'), findsOneWidget);
    expect(find.text('Pas encore d\'avis.'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.text('D\'abord décrire le besoin'), findsOneWidget);

    await tester.tap(find.text('D\'abord décrire le besoin'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Ce bouton renvoie à l\'accueil Marketplace pour décrire le besoin.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Besoin confirmé'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Demander un devis'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Le besoin confirmé et ce prestataire partent vers le formulaire de devis.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compétences'));
    await tester.pumpAndSettle();
    expect(find.text('Déménagement'), findsOneWidget);
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    expect(find.text('Conduite poids lourd'), findsOneWidget);
    expect(
      find.text('Marketplace compare ces pastilles au besoin extrait.'),
      findsOneWidget,
    );
    await tester.enterText(find.byKey(const Key('champ-competence')), 'Soudure');
    await tester.tap(find.byKey(const Key('ajouter-competence')));
    await tester.pumpAndSettle();
    expect(find.text('Soudure'), findsOneWidget);
    expect(find.text('En attente'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tarifs'));
    await tester.pumpAndSettle();
    expect(find.textContaining('150 DT'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Prochain créneau'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(
        'Samedi matin ne correspond que si ce bloc est ouvert et libre.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Sam'));
    await tester.pumpAndSettle();
    expect(find.text('Prestation confirmée'), findsOneWidget);
    expect(find.text('Fermé'), findsOneWidget);
    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();
    expect(find.text('Fermé'), findsNothing);
    expect(find.text('Prestation confirmée'), findsOneWidget);
  });

  testWidgets('Masquer un service replie le tableau, puis on en publie un', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NexusApp());
    await tester.tap(find.text('Services & prestataires'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mes services'));
    await tester.pumpAndSettle();
    expect(find.text('Déménagement'), findsOneWidget);
    expect(find.text('Actif'), findsOneWidget);

    await tester.tap(find.text('Masquer'));
    await tester.pumpAndSettle();
    expect(find.text('Masqué'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Aucun service n\'est publié.'), findsOneWidget);
    expect(find.text('Mes services'), findsNothing);

    await tester.tap(find.text('Ajouter un service'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transport de meubles'));
    await tester.enterText(
      find.byKey(const Key('champ-description')),
      'Murs et plafonds.',
    );
    await tester.enterText(find.byKey(const Key('champ-ville')), 'Tunis');
    await tester.tap(find.text('Envoyer la demande'));
    await tester.pumpAndSettle();

    expect(find.text('Aucun service n\'est publié.'), findsOneWidget);
    expect(find.textContaining('Transport de meubles'), findsOneWidget);

    await tester.tap(find.text('Approbation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Approuver'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Mes services'), findsOneWidget);
    await tester.tap(find.text('Mes services'));
    await tester.pumpAndSettle();
    expect(find.text('Transport de meubles'), findsOneWidget);
    expect(find.text('Déménagement'), findsOneWidget);
    expect(find.text('Actif'), findsOneWidget);
    expect(find.text('Masqué'), findsOneWidget);
  });
}
