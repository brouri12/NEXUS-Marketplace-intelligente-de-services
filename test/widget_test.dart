import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_android_app/app/nexus_app.dart';

void main() {
  testWidgets('La gestion communication et réclamation est l accueil', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NexusApp());

    expect(find.text('NEXUS'), findsOneWidget);
    expect(find.text('Messages').first, findsOneWidget);
    expect(find.text('Vos dossiers, vos échanges'), findsOneWidget);
    expect(find.text('Utilisateurs'), findsNothing);
  });

  testWidgets('La gestion ouvre les conversations et les notifications', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NexusApp());

    expect(find.text('Vos dossiers, vos échanges'), findsOneWidget);
    await tester.tap(find.text('Amine Ben Salem').first);
    await tester.pumpAndSettle();
    expect(find.text('Dossier : Devis envoyé'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.notifications_none));
    await tester.pumpAndSettle();
    expect(find.text('À ne pas manquer'), findsOneWidget);

    await tester.tap(find.byTooltip('Réglages des notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Restez informé'), findsOneWidget);
  });
}
