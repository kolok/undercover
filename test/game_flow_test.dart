import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undercover/game/game_controller.dart';
import 'package:undercover/main.dart';
import 'package:undercover/models/player.dart';
import 'package:undercover/models/word_pair.dart';
import 'package:undercover/screens/elimination_screen.dart';
import 'package:undercover/theme.dart';

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
  testWidgets('partie complète à 3 joueurs, de l\'accueil au résultat',
      (tester) async {
    await tester.pumpWidget(const UndercoverApp());
    await tester.tap(find.text('Démarrer la partie'));
    await tester.pumpAndSettle();

    // 6 joueurs par défaut : on descend à 3 (1 undercover, 0 Mr White).
    for (var i = 0; i < 3; i++) {
      await tester
          .tap(find.widgetWithIcon(IconButton, Icons.remove_rounded).first);
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

    await tester.tap(find.text('Rejouer'));
    await tester.pumpAndSettle();
    expect(find.text('0 / 3 cartes distribuées'), findsOneWidget);
  });

  testWidgets('Mr White éliminé peut deviner le mot des civils',
      (tester) async {
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
    final mrWhite =
        game.cards.firstWhere((p) => p.role == Role.mrWhite);
    game.eliminate(mrWhite.cardId);

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      home: EliminationScreen(controller: game, player: mrWhite),
    ));

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
}
