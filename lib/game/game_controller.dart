import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/word_pairs.dart';
import '../models/player.dart';
import '../models/word_pair.dart';

/// Étape courante de la partie.
enum GamePhase {
  /// Les joueurs choisissent leur carte et découvrent leur mot.
  distribution,

  /// Tour de table : chacun donne son indice à l'oral.
  roundTable,

  /// Les joueurs désignent sur l'écran la carte du joueur éliminé.
  voting,

  /// La partie est terminée, un camp a gagné.
  finished,
}

/// Configuration choisie sur l'écran « Nombre de joueurs ».
@immutable
class GameSettings {
  const GameSettings({
    required this.playerCount,
    required this.undercoverCount,
    required this.mrWhiteCount,
  });

  final int playerCount;
  final int undercoverCount;
  final int mrWhiteCount;

  int get civilianCount => playerCount - undercoverCount - mrWhiteCount;

  static const int minPlayers = 3;
  static const int maxPlayers = 10;
  static const int maxUndercover = 3;
  static const int maxMrWhite = 2;

  /// Les civils doivent rester strictement majoritaires : imposteurs < moitié.
  static int maxImpostorsFor(int playerCount) => (playerCount - 1) ~/ 2;

  /// Ramène la configuration dans les bornes valides après un changement.
  GameSettings normalized() {
    final players = playerCount.clamp(minPlayers, maxPlayers);
    final maxImpostors = maxImpostorsFor(players);
    final undercover =
        undercoverCount.clamp(1, min(maxUndercover, maxImpostors)).toInt();
    final mrWhite = mrWhiteCount
        .clamp(0, min(maxMrWhite, maxImpostors - undercover))
        .toInt();
    return GameSettings(
      playerCount: players,
      undercoverCount: undercover,
      mrWhiteCount: mrWhite,
    );
  }

  GameSettings copyWith({int? playerCount, int? undercoverCount, int? mrWhiteCount}) {
    return GameSettings(
      playerCount: playerCount ?? this.playerCount,
      undercoverCount: undercoverCount ?? this.undercoverCount,
      mrWhiteCount: mrWhiteCount ?? this.mrWhiteCount,
    ).normalized();
  }
}

/// Contient l'état d'une partie et toutes les règles associées.
class GameController extends ChangeNotifier {
  GameController(this.settings, {Random? random, List<WordPair>? wordPairs})
      : _random = random ?? Random(),
        _wordPairs = wordPairs ?? kWordPairs {
    _deal();
  }

  final GameSettings settings;
  final Random _random;
  final List<WordPair> _wordPairs;

  late WordPair _words;
  late List<Player> _cards;

  GamePhase _phase = GamePhase.distribution;
  Winner? _winner;
  int? _firstSpeakerCardId;
  int _roundNumber = 1;

  /// Mot des civils, révélé seulement en fin de partie ou si Mr White le devine.
  WordPair get words => _words;

  /// Les cartes dans l'ordre d'affichage de l'écran de distribution.
  List<Player> get cards => List.unmodifiable(_cards);

  GamePhase get phase => _phase;
  Winner? get winner => _winner;
  int get roundNumber => _roundNumber;

  List<Player> get alivePlayers => _cards.where((p) => p.isAlive).toList();

  int get takenCardCount => _cards.where((p) => p.isTaken).length;

  bool get isDistributionComplete => takenCardCount == settings.playerCount;

  /// Distribue les rôles au hasard sur les cartes et tire une paire de mots.
  void _deal() {
    _words = _wordPairs[_random.nextInt(_wordPairs.length)];
    final roles = <Role>[
      ...List.filled(settings.undercoverCount, Role.undercover),
      ...List.filled(settings.mrWhiteCount, Role.mrWhite),
      ...List.filled(settings.civilianCount, Role.civilian),
    ]..shuffle(_random);
    _cards = [
      for (var i = 0; i < roles.length; i++) Player(cardId: i, role: roles[i]),
    ];
  }

  /// Le mot à afficher au joueur ; `null` pour Mr White qui n'en a pas.
  String? secretWordFor(Player player) => switch (player.role) {
        Role.civilian => _words.civilian,
        Role.undercover => _words.undercover,
        Role.mrWhite => null,
      };

  /// Un joueur choisit une carte encore libre et donne son nom.
  void claimCard(int cardId, String name) {
    final player = _cards[cardId];
    assert(!player.isTaken, 'Cette carte a déjà été choisie.');
    final rank = takenCardCount;
    player.name = name.trim().isEmpty ? 'Joueur ${rank + 1}' : name.trim();
    player.pickOrder = rank;
    notifyListeners();
  }

  /// Nom proposé par défaut au prochain joueur qui prend une carte.
  String get suggestedName => 'Joueur ${takenCardCount + 1}';

  /// Démarre le premier tour de table une fois toutes les cartes distribuées.
  void startRoundTable() {
    assert(isDistributionComplete, 'Tous les joueurs doivent avoir une carte.');
    _phase = GamePhase.roundTable;
    _pickFirstSpeaker();
    notifyListeners();
  }

  /// Ordre de passage : ordre de sélection des cartes, à partir du premier
  /// joueur désigné par l'application (jamais un Mr White).
  List<Player> get speakingOrder {
    final alive = alivePlayers..sort((a, b) => a.pickOrder!.compareTo(b.pickOrder!));
    if (alive.isEmpty) return alive;
    final start = alive.indexWhere((p) => p.cardId == _firstSpeakerCardId);
    if (start <= 0) return alive;
    return [...alive.sublist(start), ...alive.sublist(0, start)];
  }

  Player? get firstSpeaker =>
      speakingOrder.isEmpty ? null : speakingOrder.first;

  void _pickFirstSpeaker() {
    final candidates =
        alivePlayers.where((p) => p.role != Role.mrWhite).toList();
    final pool = candidates.isEmpty ? alivePlayers : candidates;
    _firstSpeakerCardId = pool[_random.nextInt(pool.length)].cardId;
  }

  /// Fin du tour de table : place les joueurs en phase de vote.
  void startVote() {
    _phase = GamePhase.voting;
    notifyListeners();
  }

  /// Élimine le joueur désigné par le vote et révèle son rôle.
  ///
  /// Si c'est un Mr White, la partie attend sa tentative de devinette avant
  /// de conclure : voir [submitMrWhiteGuess].
  Player eliminate(int cardId) {
    final player = _cards[cardId];
    player.isAlive = false;
    player.isRevealed = true;
    if (player.role != Role.mrWhite) {
      _resolveOutcome();
    }
    notifyListeners();
    return player;
  }

  /// Tentative de Mr White éliminé : renvoie vrai s'il a trouvé le mot.
  bool submitMrWhiteGuess(String guess) {
    final found = _matchesCivilianWord(guess);
    if (found) {
      _winner = Winner.mrWhiteGuess;
      _phase = GamePhase.finished;
    } else {
      _resolveOutcome();
    }
    notifyListeners();
    return found;
  }

  /// Vérifie les conditions de victoire après une élimination.
  void _resolveOutcome() {
    final impostors = alivePlayers.where((p) => p.isImpostor).length;
    final civilians = alivePlayers.where((p) => p.isCivilian).length;
    if (impostors == 0) {
      _winner = Winner.civilians;
      _phase = GamePhase.finished;
    } else if (civilians <= 1) {
      _winner = Winner.undercovers;
      _phase = GamePhase.finished;
    } else {
      _phase = GamePhase.roundTable;
    }
  }

  /// Enchaîne sur le tour de table suivant, avec un nouveau premier joueur.
  void startNextRound() {
    assert(_phase == GamePhase.roundTable);
    _roundNumber++;
    _pickFirstSpeaker();
    notifyListeners();
  }

  bool _matchesCivilianWord(String guess) {
    final a = _normalize(guess);
    return a.isNotEmpty && a == _normalize(_words.civilian);
  }

  /// Comparaison tolérante : casse, accents, ponctuation et pluriel ignorés.
  static String _normalize(String value) {
    const accents = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿœæ';
    const plain = ['a', 'a', 'a', 'a', 'a', 'a', 'c', 'e', 'e', 'e', 'e', 'i',
        'i', 'i', 'i', 'n', 'o', 'o', 'o', 'o', 'o', 'u', 'u', 'u', 'u', 'y',
        'y', 'oe', 'ae'];
    final buffer = StringBuffer();
    for (final rune in value.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      final index = accents.indexOf(char);
      if (index >= 0) {
        buffer.write(plain[index]);
      } else if (RegExp(r'[a-z0-9]').hasMatch(char)) {
        buffer.write(char);
      }
    }
    var result = buffer.toString();
    if (result.length > 3 && result.endsWith('s')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }
}
