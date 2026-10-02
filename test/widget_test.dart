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
}
