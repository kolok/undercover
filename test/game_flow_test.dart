import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undercover/game/game_controller.dart';
import 'package:undercover/l10n/l10n.dart';
import 'package:undercover/l10n/locale_controller.dart';
import 'package:undercover/main.dart';
import 'package:undercover/models/player.dart';
import 'package:undercover/models/word_pair.dart';
import 'package:undercover/screens/elimination_screen.dart';
import 'package:undercover/theme.dart';

/// Les tests fixent la langue : les textes attendus sont ceux du français.
UndercoverApp frenchApp() =>
    UndercoverApp(locales: LocaleController(initialLocale: const Locale('fr')));

/// Enveloppe un écran isolé avec les traductions françaises.
Widget frenchHost(Widget home) => MaterialApp(
  theme: buildAppTheme(),
  locale: const Locale('fr'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

/// Fait choisir une carte, saisir un nom et découvrir le mot secret.
Future<void> takeCard(WidgetTester tester, String name) async {
  await tester.tap(find.text('Libre').first);
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), name);
  await tester.tap(find.text('Valider'));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(GestureDetector).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('J\'ai vu, joueur suivant'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('partie complète à 3 joueurs, de l\'accueil au résultat', (
    tester,
  ) async {
    await tester.pumpWidget(frenchApp());
    await tester.tap(find.text('Démarrer la partie'));
    await tester.pumpAndSettle();

    // 6 joueurs par défaut : on descend à 3 (1 undercover, 0 Mr White).
    for (var i = 0; i < 3; i++) {
      await tester.tap(
        find.widgetWithIcon(IconButton, Icons.remove_rounded).first,
      );
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Jouer'));
    await tester.pumpAndSettle();

    for (final name in ['Ana', 'Bob', 'Cleo']) {
      await takeCard(tester, name);
    }
    expect(find.text('Tout le monde a son mot !'), findsOneWidget);

    await tester.tap(find.text('Commencer le tour de table'));
    await tester.pumpAndSettle();
    expect(find.text('Manche 1'), findsOneWidget);

    await tester.tap(find.text('Finir le tour'));
    await tester.pumpAndSettle();
    expect(find.text('Qui est éliminé ?'), findsOneWidget);

    await tester.tap(find.text('Ana'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Éliminer'));
    await tester.pumpAndSettle();
    expect(find.text('ÉLIMINATION'), findsOneWidget);
    expect(find.text('Son mot reste secret.'), findsOneWidget);

    // À 3 joueurs, une seule élimination suffit à conclure la partie.
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('FIN DE PARTIE'), findsOneWidget);
    expect(find.text('Mot des civils'), findsOneWidget);

    // Rejouer conserve l'équipe : l'application appelle les joueurs elle-même.
    await tester.tap(find.text('Rejouer'));
    await tester.pumpAndSettle();
    expect(find.text('0 / 3 cartes distribuées'), findsOneWidget);
    final first = ['Ana', 'Bob', 'Cleo'].firstWhere(
      (name) => find
          .text('Au tour de $name de choisir une carte')
          .evaluate()
          .isNotEmpty,
    );

    // Choisir une carte n'ouvre plus la saisie du nom : il est déjà connu.
    await tester.tap(find.text('Libre').first);
    await tester.pumpAndSettle();
    expect(find.text('TON NOM'), findsNothing);
    expect(find.text(first.toUpperCase()), findsOneWidget);
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('J\'ai vu, joueur suivant'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 3 cartes distribuées'), findsOneWidget);
  });

  testWidgets('Mr White éliminé peut deviner le mot des civils', (
    tester,
  ) async {
    final game = GameController(
      const GameSettings(playerCount: 6, undercoverCount: 1, mrWhiteCount: 1),
      random: Random(7),
      wordPairs: const [WordPair('Citron', 'Orange')],
    );
    for (final card in game.cards) {
      game.claimCard(card.cardId, 'Joueur ${card.cardId + 1}');
    }
    game.startRoundTable();
    game.startVote();
    final mrWhite = game.cards.firstWhere((p) => p.role == Role.mrWhite);
    game.eliminate(mrWhite.cardId);

    await tester.pumpWidget(
      frenchHost(EliminationScreen(controller: game, player: mrWhite)),
    );

    expect(find.text('était Mr White'), findsOneWidget);
    await tester.tap(find.text('Deviner le mot des civils'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'citron');
    await tester.tap(find.text('Valider ma proposition'));
    await tester.pumpAndSettle();

    expect(find.text('Trouvé !'), findsOneWidget);
    expect(find.text('Citron'), findsOneWidget);
    expect(game.winner, Winner.mrWhiteGuess);
  });

  testWidgets('un nom déjà pris est refusé à la saisie', (tester) async {
    await tester.pumpWidget(frenchApp());
    await tester.tap(find.text('Démarrer la partie'));
    await tester.pumpAndSettle();

    for (var i = 0; i < 3; i++) {
      await tester.tap(
        find.widgetWithIcon(IconButton, Icons.remove_rounded).first,
      );
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Jouer'));
    await tester.pumpAndSettle();

    await takeCard(tester, 'Ana');

    // Le deuxième joueur tente le même nom, à la casse près.
    await tester.tap(find.text('Libre').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ana');
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ce nom est déjà pris, trouve-en un autre.'),
      findsOneWidget,
    );
    expect(
      find.text('Valider'),
      findsOneWidget,
      reason: 'on reste sur la saisie',
    );

    // Un autre nom débloque la validation.
    await tester.enterText(find.byType(TextField), 'Bob');
    await tester.pumpAndSettle();
    expect(
      find.text('Ce nom est déjà pris, trouve-en un autre.'),
      findsNothing,
    );
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();
    expect(find.text('BOB'), findsOneWidget, reason: 'la carte est attribuée');
  });
}
