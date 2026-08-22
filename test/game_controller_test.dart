import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:undercover/game/game_controller.dart';
import 'package:undercover/models/player.dart';
import 'package:undercover/models/word_pair.dart';

const _pairs = [WordPair('Citron', 'Orange')];

GameController buildGame({
  int players = 6,
  int undercover = 1,
  int mrWhite = 1,
}) {
  return GameController(
    GameSettings(
      playerCount: players,
      undercoverCount: undercover,
      mrWhiteCount: mrWhite,
    ),
    random: Random(42),
    wordPairs: _pairs,
  );
}

/// Distribue toutes les cartes puis lance le tour de table.
void dealAll(GameController game) {
  for (final card in game.cards) {
    game.claimCard(card.cardId, 'J${card.cardId + 1}');
  }
  game.startRoundTable();
}

Player firstWhere(GameController game, bool Function(Player) test) =>
    game.alivePlayers.firstWhere(test);

void main() {
  group('GameSettings', () {
    test('garde les civils majoritaires', () {
      const settings = GameSettings(
        playerCount: 6,
        undercoverCount: 3,
        mrWhiteCount: 2,
      );
      final normalized = settings.normalized();
      expect(normalized.undercoverCount + normalized.mrWhiteCount, 2);
      expect(normalized.civilianCount, 4);
      expect(normalized.civilianCount > 6 / 2, isTrue);
    });

    test('impose au moins un undercover', () {
      const settings = GameSettings(
        playerCount: 3,
        undercoverCount: 0,
        mrWhiteCount: 2,
      );
      final normalized = settings.normalized();
      expect(normalized.undercoverCount, 1);
      expect(normalized.mrWhiteCount, 0);
      expect(normalized.civilianCount, 2);
    });

    test('réajuste les rôles quand le nombre de joueurs baisse', () {
      const settings = GameSettings(
        playerCount: 9,
        undercoverCount: 3,
        mrWhiteCount: 1,
      );
      final smaller = settings.copyWith(playerCount: 4);
      expect(smaller.undercoverCount, 1);
      expect(smaller.mrWhiteCount, 0);
    });
  });

  group('Distribution', () {
    test('crée le bon nombre de cartes et de rôles', () {
      final game = buildGame(players: 7, undercover: 2, mrWhite: 1);
      expect(game.cards.length, 7);
      expect(game.cards.where((p) => p.role == Role.undercover).length, 2);
      expect(game.cards.where((p) => p.role == Role.mrWhite).length, 1);
      expect(game.cards.where((p) => p.isCivilian).length, 4);
    });

    test('donne le mot correspondant au rôle, rien pour Mr White', () {
      final game = buildGame();
      for (final card in game.cards) {
        expect(
          game.secretWordFor(card),
          switch (card.role) {
            Role.civilian => 'Citron',
            Role.undercover => 'Orange',
            Role.mrWhite => null,
          },
        );
      }
    });

    test('une carte prise fixe l\'ordre de passage', () {
      final game = buildGame(players: 3, undercover: 1, mrWhite: 0);
      game.claimCard(2, 'Zoé');
      game.claimCard(0, 'Alex');
      expect(game.cards[2].pickOrder, 0);
      expect(game.cards[0].pickOrder, 1);
      expect(game.isDistributionComplete, isFalse);
      game.claimCard(1, '  ');
      expect(game.cards[1].name, 'Joueur 3');
      expect(game.isDistributionComplete, isTrue);
    });

    test('un nom déjà pris est refusé, casse ignorée', () {
      final game = buildGame(players: 3, undercover: 1, mrWhite: 0);
      game.claimCard(0, 'Zoé');
      expect(game.isNameTaken('zoé'), isTrue);
      expect(game.isNameTaken('  ZOÉ '), isTrue);
      expect(game.isNameTaken('Alex'), isFalse);
      expect(game.takenNames, ['Zoé']);
    });

    test('le nom proposé saute les numéros déjà utilisés', () {
      final game = buildGame(players: 3, undercover: 1, mrWhite: 0);
      expect(game.suggestedName, 'Joueur 1');
      game.claimCard(0, 'Joueur 2');
      expect(game.suggestedName, 'Joueur 3');
      game.claimCard(1, 'Joueur 3');
      expect(game.suggestedName, 'Joueur 4');
      game.claimCard(2, '   ');
      expect(game.cards[2].name, 'Joueur 4');
    });
  });

  group('Tour de table', () {
    test('le premier joueur n\'est jamais Mr White', () {
      for (var seed = 0; seed < 50; seed++) {
        final game = GameController(
          const GameSettings(
              playerCount: 5, undercoverCount: 1, mrWhiteCount: 1),
          random: Random(seed),
          wordPairs: _pairs,
        );
        dealAll(game);
        expect(game.firstSpeaker!.role, isNot(Role.mrWhite));
      }
    });

    test('conserve l\'ordre de sélection à partir du premier joueur', () {
      final game = buildGame(players: 5, undercover: 1, mrWhite: 0);
      dealAll(game);
      final order = game.speakingOrder.map((p) => p.pickOrder!).toList();
      final start = order.first;
      expect(order, [for (var i = 0; i < 5; i++) (start + i) % 5]);
    });

    test('les joueurs éliminés sortent de l\'ordre de passage', () {
      final game = buildGame(players: 6, undercover: 1, mrWhite: 0);
      dealAll(game);
      final victim = firstWhere(game, (p) => p.isCivilian);
      game.startVote();
      game.eliminate(victim.cardId);
      expect(game.speakingOrder.contains(victim), isFalse);
      expect(game.speakingOrder.length, 5);
    });
  });

  group('Conditions de victoire', () {
    test('les civils gagnent quand tous les imposteurs sont éliminés', () {
      final game = buildGame(players: 5, undercover: 1, mrWhite: 0);
      dealAll(game);
      game.startVote();
      final undercover = firstWhere(game, (p) => p.role == Role.undercover);
      game.eliminate(undercover.cardId);
      expect(game.winner, Winner.civilians);
      expect(game.phase, GamePhase.finished);
    });

    test('les imposteurs gagnent quand il ne reste qu\'un civil', () {
      final game = buildGame(players: 3, undercover: 1, mrWhite: 0);
      dealAll(game);
      game.startVote();
      game.eliminate(firstWhere(game, (p) => p.isCivilian).cardId);
      expect(game.winner, Winner.undercovers);
    });

    test('la partie continue tant qu\'aucun camp ne l\'emporte', () {
      final game = buildGame(players: 7, undercover: 2, mrWhite: 0);
      dealAll(game);
      game.startVote();
      game.eliminate(firstWhere(game, (p) => p.isCivilian).cardId);
      expect(game.winner, isNull);
      expect(game.phase, GamePhase.roundTable);
      game.startNextRound();
      expect(game.roundNumber, 2);
    });

    test('un rôle éliminé est révélé, jamais son mot', () {
      final game = buildGame(players: 7, undercover: 2, mrWhite: 0);
      dealAll(game);
      game.startVote();
      final victim = firstWhere(game, (p) => p.isCivilian);
      game.eliminate(victim.cardId);
      expect(victim.isRevealed, isTrue);
      expect(game.cards.where((p) => p.isRevealed).length, 1);
    });
  });

  group('Mr White', () {
    test('gagne s\'il devine le mot des civils', () {
      final game = buildGame(players: 6, undercover: 1, mrWhite: 1);
      dealAll(game);
      game.startVote();
      game.eliminate(firstWhere(game, (p) => p.role == Role.mrWhite).cardId);
      expect(game.winner, isNull, reason: 'La partie attend sa devinette');
      expect(game.submitMrWhiteGuess('  citrons '), isTrue);
      expect(game.winner, Winner.mrWhiteGuess);
      expect(game.phase, GamePhase.finished);
    });

    test('est simplement éliminé s\'il se trompe', () {
      final game = buildGame(players: 6, undercover: 1, mrWhite: 1);
      dealAll(game);
      game.startVote();
      game.eliminate(firstWhere(game, (p) => p.role == Role.mrWhite).cardId);
      expect(game.submitMrWhiteGuess('banane'), isFalse);
      expect(game.winner, isNull);
      expect(game.phase, GamePhase.roundTable);
    });

    test('éliminer le dernier imposteur Mr White qui échoue fait gagner les civils',
        () {
      final game = buildGame(players: 5, undercover: 1, mrWhite: 1);
      dealAll(game);
      game.startVote();
      game.eliminate(firstWhere(game, (p) => p.role == Role.undercover).cardId);
      expect(game.winner, isNull);
      game.startNextRound();
      game.startVote();
      game.eliminate(firstWhere(game, (p) => p.role == Role.mrWhite).cardId);
      expect(game.submitMrWhiteGuess('avion'), isFalse);
      expect(game.winner, Winner.civilians);
    });

    test('la devinette ignore accents, casse et ponctuation', () {
      final game = buildGame(players: 6, undercover: 1, mrWhite: 1);
      dealAll(game);
      game.startVote();
      game.eliminate(firstWhere(game, (p) => p.role == Role.mrWhite).cardId);
      expect(game.submitMrWhiteGuess('CITRON !'), isTrue);
    });
  });
}
