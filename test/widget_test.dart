import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undercover/l10n/locale_controller.dart';
import 'package:undercover/main.dart';

/// Les tests fixent la langue : les textes attendus sont ceux du français.
UndercoverApp frenchApp() =>
    UndercoverApp(locales: LocaleController(initialLocale: const Locale('fr')));

void main() {
  const rateLabel = 'Noter sur le Play Store';

  Future<void> openAbout(WidgetTester tester) async {
    await tester.pumpWidget(frenchApp());
    await tester.tap(find.text('À propos'));
    await tester.pumpAndSettle();
    expect(find.text('À PROPOS'), findsOneWidget);
  }

  testWidgets('la page À propos invite à noter le jeu sur Android', (
    tester,
  ) async {
    await tester.pumpWidget(frenchApp());
    expect(find.text(rateLabel), findsNothing);

    await openAbout(tester);
    expect(find.textContaining('sans publicité'), findsOneWidget);
    expect(find.text(rateLabel), findsOneWidget);
  });

  testWidgets('pas d\'invitation Play Store sur iOS', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await openAbout(tester);
    expect(find.text(rateLabel), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('on peut aller de l\'accueil à la distribution des cartes', (
    tester,
  ) async {
    await tester.pumpWidget(frenchApp());

    expect(find.text('UNDERCOVER'), findsOneWidget);

    await tester.tap(find.text('Démarrer la partie'));
    await tester.pumpAndSettle();
    expect(find.text('NOMBRE DE JOUEURS'), findsOneWidget);

    // Configuration par défaut : 6 joueurs, 1 undercover, 1 Mr White.
    expect(find.text('4'), findsOneWidget); // civils
    await tester.tap(
      find.widgetWithIcon(IconButton, Icons.remove_rounded).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget); // joueurs

    await tester.tap(find.text('Jouer'));
    await tester.pumpAndSettle();
    expect(find.text('JEU'), findsOneWidget);
    expect(find.text('0 / 5 cartes distribuées'), findsOneWidget);
  });

  testWidgets('un joueur choisit une carte, se nomme et voit son mot', (
    tester,
  ) async {
    await tester.pumpWidget(frenchApp());
    await tester.tap(find.text('Démarrer la partie'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jouer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Libre').first);
    await tester.pumpAndSettle();
    expect(find.text('Comment t\'appelles-tu ?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Nico');
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();

    // Le mot reste caché tant que le joueur n'a pas appuyé sur la carte.
    expect(find.text('Appuie pour découvrir\nton mot secret'), findsOneWidget);
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('J\'ai vu, joueur suivant'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 6 cartes distribuées'), findsOneWidget);
    expect(find.text('Nico'), findsOneWidget);
  });
}
