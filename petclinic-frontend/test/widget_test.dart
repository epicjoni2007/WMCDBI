// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wmcdbi_petclinic_frontend/pages/owners_page.dart';
import 'package:wmcdbi_petclinic_frontend/widgets/owner_card.dart';

void main() {
  testWidgets('OwnersPage zeigt die Owner aus dem MockService an und zeigt Details nach Tap', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OwnersPage()));

    // Warte auf asynchrone Laden-Operationen (MockService hat eine kleine Verzögerung)
    await tester.pumpAndSettle();

    // Mindestens einige Owner-Card-Widgets sollten angezeigt werden
    expect(find.byType(OwnerCard), findsWidgets);

    // Überprüfe, dass ein bekannter Name in der Liste sichtbar ist
    expect(find.text('Hans Müller'), findsOneWidget);

    // Tippe die erste OwnerCard an, um die Detailansicht zu öffnen
    final firstCard = find.byType(OwnerCard).first;
    await tester.tap(firstCard);
    await tester.pumpAndSettle();

    // Nach dem Tippen sollte der Name des Owners auch in der Detail-Ansicht erscheinen
    expect(find.text('Hans Müller'), findsWidgets);
  });
}
