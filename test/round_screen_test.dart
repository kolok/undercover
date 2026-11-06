import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undercover/game/game_controller.dart';
import 'package:undercover/l10n/l10n.dart';
import 'package:undercover/models/player.dart';
import 'package:undercover/models/word_pair.dart';
import 'package:undercover/screens/round_screen.dart';
import 'package:undercover/theme.dart';

Widget frenchHost(Widget home) => MaterialApp(
  theme: buildAppTheme(),
  locale: const Locale('fr'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

GameController fourPlayerGame() {
  final game = GameController(
    const GameSettings(playerCount: 4, undercoverCount: 1, mrWhiteCount: 0),
    random: Random(3),
    wordPairs: const [WordPair('Citron', 'Orange')],
  );
  for (final card in game.cards) {
    game.claimCard(card.cardId, 'Joueur ${card.cardId + 1}');
  }
  game.startRoundTable();
  game.startVote();
  return game;
}

void main() {
  testWidgets('le vote peut être annulé avant élimination', (tester) async {
    final game = fourPlayerGame();
    game.cards.first.name = 'Ana';

    await tester.pumpWidget(frenchHost(RoundScreen(controller: game)));

    await tester.tap(find.text('Ana'));
    await tester.pumpAndSettle();
    expect(find.text('Éliminer Ana ?'), findsOneWidget);

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(find.text('Qui est éliminé ?'), findsOneWidget);
  });

  testWidgets('après une élimination le vote rappelle les joueurs éliminés', (
    tester,
  ) async {
    final game = fourPlayerGame();
    final target = game.cards.firstWhere((p) => p.role == Role.civilian);
    target.name = 'Ana';

    await tester.pumpWidget(frenchHost(RoundScreen(controller: game)));

    await tester.tap(find.text('Ana'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Éliminer'));
    await tester.pumpAndSettle();
    expect(find.text('ÉLIMINATION'), findsOneWidget);

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Manche 2'), findsOneWidget);

    await tester.tap(find.text('Finir le tour'));
    await tester.pumpAndSettle();
    expect(find.text('Qui est éliminé ?'), findsOneWidget);
    expect(find.textContaining('Ana ·'), findsOneWidget);
  });
}
