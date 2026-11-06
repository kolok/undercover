import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undercover/l10n/locale_controller.dart';
import 'package:undercover/main.dart';

UndercoverApp frenchApp() =>
    UndercoverApp(locales: LocaleController(initialLocale: const Locale('fr')));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('les règles du jeu s\'affichent dans une feuille modale', (
    tester,
  ) async {
    await tester.pumpWidget(frenchApp());

    await tester.tap(find.text('Règles du jeu'));
    await tester.pumpAndSettle();

    expect(find.text('Mise en place'), findsOneWidget);
    expect(find.text('Victoire'), findsOneWidget);
  });

  testWidgets('le sélecteur de langue change l\'interface', (tester) async {
    await tester.pumpWidget(frenchApp());

    await tester.tap(find.byIcon(Icons.language_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Langue'), findsOneWidget);
    expect(find.text('Langue du système'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Start the game'), findsOneWidget);
    expect(find.text('Démarrer la partie'), findsNothing);
  });
}
