import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_android_app/app/nexus_app.dart';
import 'package:flutter_android_app/gestions/utilisateurs/utilisateurs_module.dart';

void main() {
  testWidgets('L application s ouvre sur la connexion', (WidgetTester tester) async {
    await tester.pumpWidget(const NexusApp());

    expect(find.text('NEXUS'), findsOneWidget);
    expect(find.byKey(const Key('sign-in-email')), findsOneWidget);
    expect(find.text('Marketplace'), findsNothing);
  });

  testWidgets('La barre laterale s ouvre apres la connexion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NexusApp());
    await tester.enterText(find.byKey(const Key('sign-in-email')), 'admin@nexus.app');
    await tester.enterText(find.byKey(const Key('sign-in-password')), 'nexus123');
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('Nour Mansour'), findsWidgets);
    expect(find.text('Profil'), findsWidgets);
    expect(find.byIcon(Icons.logout), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Marketplace'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Utilisateurs'),
      -80,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('Utilisateurs')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Utilisateurs'));
    await tester.pumpAndSettle();

    expect(find.text('Sara Ben Ali'), findsOneWidget);
    expect(find.text('Amine Trabelsi'), findsOneWidget);

    await tester.tap(find.byTooltip('Modifier Sara Ben Ali'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('edit-city')), 'Ariana');
    await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Sara Ben Ali'), findsOneWidget);
    await tester.tap(find.text('Sara Ben Ali'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ariana'), findsOneWidget);

    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Modifier Amine Trabelsi'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Déménagement'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Camion'), findsOneWidget);
    expect(find.text('Manutention'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('edit-rate')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(
      tester.widget<TextField>(find.byKey(const Key('edit-rate'))).controller?.text,
      '80',
    );
    expect(find.text('Samedi'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('edit-presentation')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(
      tester.widget<TextField>(find.byKey(const Key('edit-presentation'))).controller?.text,
      'Camion et deux personnes pour un déménagement.',
    );

    utilisateursStore.signOut();
  });

  testWidgets('L admin ouvre l interface client', (WidgetTester tester) async {
    utilisateursStore.signOut();
    await tester.pumpWidget(const NexusApp());
    await tester.enterText(find.byKey(const Key('sign-in-email')), 'admin@nexus.app');
    await tester.enterText(find.byKey(const Key('sign-in-password')), 'nexus123');
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Interface client'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsNothing);
    expect(find.text('Marketplace'), findsWidgets);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Interface admin'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byIcon(Icons.logout), findsOneWidget);

    utilisateursStore.signOut();
  });

  testWidgets('Le prestataire est aussi client', (WidgetTester tester) async {
    utilisateursStore.signOut();
    await tester.pumpWidget(const NexusApp());
    await tester.enterText(find.byKey(const Key('sign-in-email')), 'amine@nexus.app');
    await tester.enterText(find.byKey(const Key('sign-in-password')), 'nexus123');
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Marketplace'), findsWidgets);
    expect(find.text('Services'), findsWidgets);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Client'), findsOneWidget);
    expect(find.text('Prestataire'), findsOneWidget);

    await tester.tap(find.text('Modifier le profil'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Déménagement'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Camion'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byKey(const Key('edit-rate'))).controller?.text,
      '80',
    );

    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Services'));
    await tester.pumpAndSettle();
    expect(find.text('Votre offre'), findsOneWidget);
    expect(find.text('Déménagement'), findsWidgets);

    utilisateursStore.signOut();
  });

  testWidgets('Le client a une barre en bas', (WidgetTester tester) async {
    utilisateursStore.signOut();
    await tester.pumpWidget(const NexusApp());
    await tester.enterText(find.byKey(const Key('sign-in-email')), 'sara@nexus.app');
    await tester.enterText(find.byKey(const Key('sign-in-password')), 'nexus123');
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsNothing);
    expect(find.text('Marketplace'), findsWidgets);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Devis'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Gérer les utilisateurs'), findsNothing);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Rôle'), findsNothing);

    await tester.tap(find.text('Services'));
    await tester.pumpAndSettle();
    expect(find.text('Services disponibles'), findsOneWidget);
    expect(find.text('Déménagement'), findsOneWidget);
    expect(find.text('Amine Trabelsi'), findsOneWidget);

    await tester.tap(find.text('Devis'));
    await tester.pumpAndSettle();

    expect(find.text('Devis et contrats'), findsOneWidget);

    utilisateursStore.signOut();
  });

  testWidgets('Un prestataire renseigne son metier a l inscription', (
    WidgetTester tester,
  ) async {
    utilisateursStore.signOut();
    await tester.pumpWidget(const NexusApp());
    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();

    expect(find.text('Métier'), findsNothing);

    await tester.enterText(find.byKey(const Key('sign-up-first-name')), 'Karim');
    await tester.enterText(find.byType(TextField).at(1), 'Saidi');
    await tester.enterText(find.byType(TextField).at(2), 'karim@nexus.app');
    await tester.enterText(find.byType(TextField).at(3), '22123456');
    await tester.enterText(find.byType(TextField).at(5), 'nexus123');
    await tester.enterText(find.byType(TextField).at(6), 'nexus123');

    await tester.scrollUntilVisible(
      find.byKey(const Key('sign-up-provider')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('sign-up-provider')));
    await tester.pumpAndSettle();

    expect(find.text('Métier'), findsOneWidget);
    expect(find.text('Tarif horaire'), findsOneWidget);
    expect(find.text('Disponibilités'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('sign-up-submit')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('sign-up-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Indiquez le métier.'), findsOneWidget);

    await _show(tester, find.text('Peinture'));
    await tester.tap(find.text('Peinture'));
    await tester.pumpAndSettle();
    await _show(tester, find.text('Intérieur'));
    await tester.tap(find.text('Intérieur'));
    await _show(tester, find.byKey(const Key('sign-up-rate')));
    await tester.enterText(find.byKey(const Key('sign-up-rate')), '60');
    await _show(tester, find.text('Samedi'));
    await tester.tap(find.text('Samedi'));
    await _show(tester, find.byKey(const Key('sign-up-submit')));
    await tester.tap(find.byKey(const Key('sign-up-submit')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Un administrateur doit le confirmer'),
      findsOneWidget,
    );

    await tester.tap(find.text('Retour à la connexion'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('sign-in-email')), 'karim@nexus.app');
    await tester.enterText(find.byKey(const Key('sign-in-password')), 'nexus123');
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pumpAndSettle();
    expect(find.textContaining('attend la confirmation'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('sign-in-email')), 'admin@nexus.app');
    await tester.enterText(find.byKey(const Key('sign-in-password')), 'nexus123');
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Utilisateurs'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('Utilisateurs')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Utilisateurs'));
    await tester.pumpAndSettle();
    expect(find.textContaining('En attente'), findsWidgets);

    await tester.tap(find.text('Karim Saidi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmer le compte'));
    await tester.pumpAndSettle();
    expect(find.text('Confirmer le compte'), findsNothing);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('sign-in-email')), 'karim@nexus.app');
    await tester.enterText(find.byKey(const Key('sign-in-password')), 'nexus123');
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Karim Saidi'), findsWidgets);
    expect(find.text('Peinture'), findsOneWidget);
    expect(find.text('60 TND / heure'), findsOneWidget);
    expect(find.text('Intérieur'), findsOneWidget);

    utilisateursStore.signOut();
  });
}

Future<void> _show(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    80,
    scrollable: find.byType(Scrollable).first,
  );
  await Scrollable.ensureVisible(
    tester.element(finder),
    alignment: 0.5,
  );
  await tester.pumpAndSettle();
}
