/// Rôle secret attribué à un joueur au début de la partie.
///
/// Le libellé affiché est traduit : voir l'extension `RoleLabel` dans
/// `lib/l10n/l10n.dart`.
enum Role { civilian, undercover, mrWhite }

/// Camp gagnant à la fin de la partie.
enum Winner {
  civilians,

  /// Les undercover et/ou Mr White l'emportent en restant en supériorité.
  undercovers,

  /// Mr White a deviné le mot des civils après son élimination.
  mrWhiteGuess,
}

/// Un joueur, associé à une carte de la distribution.
class Player {
  Player({required this.cardId, required this.role});

  /// Position de la carte face cachée sur l'écran de distribution.
  final int cardId;

  final Role role;

  /// Renseigné quand un joueur choisit cette carte.
  String? name;

  /// Rang de sélection de la carte, qui fixe l'ordre du tour de table.
  int? pickOrder;

  bool isAlive = true;

  /// Vrai une fois que le rôle a été révélé publiquement (élimination).
  bool isRevealed = false;

  bool get isTaken => name != null;

  bool get isCivilian => role == Role.civilian;

  /// Undercover et Mr White forment le camp opposé aux civils.
  bool get isImpostor => role != Role.civilian;
}
