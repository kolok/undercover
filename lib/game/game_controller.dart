import 'dart:math';

import 'package:flutter/foundation.dart';

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
    final undercover = undercoverCount
        .clamp(1, min(maxUndercover, maxImpostors))
        .toInt();
    final mrWhite = mrWhiteCount
        .clamp(0, min(maxMrWhite, maxImpostors - undercover))
        .toInt();
    return GameSettings(
      playerCount: players,
      undercoverCount: undercover,
      mrWhiteCount: mrWhite,
    );
  }

  GameSettings copyWith({
    int? playerCount,
    int? undercoverCount,
    int? mrWhiteCount,
  }) {
    return GameSettings(
      playerCount: playerCount ?? this.playerCount,
      undercoverCount: undercoverCount ?? this.undercoverCount,
      mrWhiteCount: mrWhiteCount ?? this.mrWhiteCount,
    ).normalized();
  }
}

/// Contient l'état d'une partie et toutes les règles associées.
class GameController extends ChangeNotifier {
  /// [wordPairs] est la liste de mots de la langue courante, chargée par
  /// [WordBank].
  ///
  /// [roster] reprend les joueurs d'une partie précédente : l'ordre de passage
  /// est conservé, seul le premier à choisir une carte est tiré au sort.
  ///
  /// [defaultPlayerName] fournit le nom proposé à un joueur qui n'en saisit
  /// pas ; l'application y branche la traduction en cours.
  GameController(
    this.settings, {
    required this.wordPairs,
    Random? random,
    List<String> roster = const [],
    String Function(int number)? defaultPlayerName,
  }) : _random = random ?? Random(),
       _defaultPlayerName = defaultPlayerName ?? _englishPlayerName {
    _deal();
    _rotatedRoster = _rotate(roster);
  }

  static String _englishPlayerName(int number) => 'Player $number';

  final GameSettings settings;

  /// La banque de mots dans laquelle la paire de la partie est tirée.
  final List<WordPair> wordPairs;

  final Random _random;
  final String Function(int number) _defaultPlayerName;

  /// Noms imposés, dans l'ordre où l'application appelle les joueurs.
  /// Vide quand l'équipe n'est pas connue à l'avance.
  late final List<String> _rotatedRoster;

  late WordPair _words;
  late List<Player> _cards;

  GamePhase _phase = GamePhase.distribution;
  Winner? _winner;
  int? _firstSpeakerCardId;
  int? _lastEliminatedCardId;
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

  /// Fait démarrer la liste des joueurs sur l'un d'eux, choisi au hasard.
  List<String> _rotate(List<String> roster) {
    if (roster.length != settings.playerCount) return const [];
    final start = _random.nextInt(roster.length);
    return [...roster.sublist(start), ...roster.sublist(0, start)];
  }

  /// Vrai quand l'application désigne elle-même qui doit prendre une carte.
  bool get hasFixedOrder => _rotatedRoster.isNotEmpty;

  /// Joueur appelé à choisir une carte, `null` si chacun se présente librement.
  String? get nextPlayerName => hasFixedOrder && !isDistributionComplete
      ? _rotatedRoster[takenCardCount]
      : null;

  /// L'équipe de la partie en cours, dans l'ordre de passage : sert à relancer
  /// une partie avec les mêmes joueurs.
  List<String> get playerNames => [
    for (final p
        in _cards.where((p) => p.isTaken).toList()
          ..sort((a, b) => a.pickOrder!.compareTo(b.pickOrder!)))
      p.name!,
  ];

  /// Distribue les rôles au hasard sur les cartes et tire une paire de mots.
  void _deal() {
    _words = wordPairs[_random.nextInt(wordPairs.length)];
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

  /// Noms déjà utilisés par les joueurs ayant pris une carte.
  List<String> get takenNames => [
    for (final p in _cards)
      if (p.isTaken) p.name!,
  ];

  /// Deux joueurs ne peuvent pas porter le même nom (casse ignorée).
  bool isNameTaken(String name) {
    final candidate = name.trim().toLowerCase();
    return takenNames.any((n) => n.toLowerCase() == candidate);
  }

  /// Un joueur choisit une carte encore libre et donne son nom.
  ///
  /// Quand l'équipe est reprise d'une partie précédente, le nom est imposé par
  /// l'ordre de passage et [name] est ignoré.
  void claimCard(int cardId, String name) {
    final player = _cards[cardId];
    assert(!player.isTaken, 'Cette carte a déjà été choisie.');
    final rank = takenCardCount;
    final imposed = hasFixedOrder ? _rotatedRoster[rank] : null;
    assert(imposed != null || !isNameTaken(name), 'Ce nom est déjà pris.');
    player.name =
        imposed ?? (name.trim().isEmpty ? suggestedName : name.trim());
    player.pickOrder = rank;
    notifyListeners();
  }

  /// Nom proposé par défaut au prochain joueur qui prend une carte, en
  /// sautant les numéros qu'un joueur se serait déjà attribués.
  String get suggestedName {
    var number = takenCardCount + 1;
    while (isNameTaken(_defaultPlayerName(number))) {
      number++;
    }
    return _defaultPlayerName(number);
  }

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
    final alive = alivePlayers
      ..sort((a, b) => a.pickOrder!.compareTo(b.pickOrder!));
    if (alive.isEmpty) return alive;
    final start = alive.indexWhere((p) => p.cardId == _firstSpeakerCardId);
    if (start <= 0) return alive;
    return [...alive.sublist(start), ...alive.sublist(0, start)];
  }

  Player? get firstSpeaker =>
      speakingOrder.isEmpty ? null : speakingOrder.first;

  void _pickFirstSpeaker() {
    final candidates = alivePlayers
        .where((p) => p.role != Role.mrWhite)
        .toList();
    final pool = candidates.isEmpty ? alivePlayers : candidates;
    _firstSpeakerCardId = pool[_random.nextInt(pool.length)].cardId;
  }

  /// Joueur encore en vie qui suit l'éliminé dans l'ordre de passage.
  ///
  /// Un Mr White est sauté, il ne commence jamais un tour de table.
  /// Renvoie `null` tant qu'aucun joueur n'a été éliminé.
  int? _speakerAfterElimination() {
    final eliminated = _lastEliminatedCardId;
    if (eliminated == null) return null;
    final seated = _cards.where((p) => p.pickOrder != null).toList()
      ..sort((a, b) => a.pickOrder!.compareTo(b.pickOrder!));
    final from = seated.indexWhere((p) => p.cardId == eliminated);
    if (from < 0) return null;
    int? fallback;
    for (var step = 1; step <= seated.length; step++) {
      final player = seated[(from + step) % seated.length];
      if (!player.isAlive) continue;
      fallback ??= player.cardId;
      if (player.role != Role.mrWhite) return player.cardId;
    }
    return fallback;
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
    _lastEliminatedCardId = cardId;
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

  /// Enchaîne sur le tour de table suivant : la parole repart du joueur qui
  /// suit celui qui vient d'être éliminé.
  void startNextRound() {
    assert(_phase == GamePhase.roundTable);
    _roundNumber++;
    final next = _speakerAfterElimination();
    if (next == null) {
      _pickFirstSpeaker();
    } else {
      _firstSpeakerCardId = next;
    }
    notifyListeners();
  }

  bool _matchesCivilianWord(String guess) {
    final a = _normalize(guess);
    return a.isNotEmpty && a == _normalize(_words.civilian);
  }

  /// Comparaison tolérante : casse, accents, ponctuation et pluriel ignorés.
  ///
  /// Les caractères couverts vont au-delà du français, pour que la devinette
  /// reste tolérante dans toutes les langues proposées.
  static String _normalize(String value) {
    const accents = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿœæß';
    const plain = [
      'a',
      'a',
      'a',
      'a',
      'a',
      'a',
      'c',
      'e',
      'e',
      'e',
      'e',
      'i',
      'i',
      'i',
      'i',
      'n',
      'o',
      'o',
      'o',
      'o',
      'o',
      'u',
      'u',
      'u',
      'u',
      'y',
      'y',
      'oe',
      'ae',
      'ss',
    ];
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
