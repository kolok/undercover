import 'package:flutter/material.dart';

import '../data/word_bank.dart';
import '../game/game_controller.dart';
import '../l10n/l10n.dart';
import '../models/player.dart';
import '../theme.dart';
import 'distribution_screen.dart';

/// Écran de fin : camp vainqueur, mots révélés et rôle de chacun.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.controller});

  final GameController controller;

  Color get _winnerColor => switch (controller.winner) {
        Winner.civilians => AppColors.civilian,
        Winner.mrWhiteGuess => AppColors.mrWhite,
        _ => AppColors.undercover,
      };

  String _title(AppLocalizations l10n) => switch (controller.winner) {
        Winner.civilians => l10n.winCivilians,
        Winner.mrWhiteGuess => l10n.winMrWhite,
        _ => _survivingImpostorsLabel(l10n),
      };

  String _subtitle(AppLocalizations l10n) => switch (controller.winner) {
        Winner.civilians => l10n.winCiviliansSubtitle,
        Winner.mrWhiteGuess => l10n.winMrWhiteSubtitle,
        _ => l10n.winImpostorsSubtitle,
      };

  String _survivingImpostorsLabel(AppLocalizations l10n) {
    final survivors = controller.alivePlayers.where((p) => p.isImpostor);
    final hasMrWhite = survivors.any((p) => p.role == Role.mrWhite);
    final hasUndercover = survivors.any((p) => p.role == Role.undercover);
    if (hasMrWhite && !hasUndercover) return l10n.winMrWhite;
    if (hasMrWhite) return l10n.winUndercoverAndMrWhite;
    return l10n.winUndercovers;
  }

  /// Relance une partie avec la même équipe : l'ordre de passage est conservé,
  /// seul le premier joueur appelé à choisir une carte change. Une nouvelle
  /// paire de mots est tirée dans la langue courante.
  Future<void> _replay(BuildContext context) async {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final navigator = Navigator.of(context);
    final pairs = await wordBank.load(language);
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => DistributionScreen(
          controller: GameController(
            controller.settings,
            wordPairs: pairs,
            roster: controller.playerNames,
            defaultPlayerName: l10n.defaultPlayerName,
          ),
        ),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final players = controller.cards.where((p) => p.isTaken).toList()
      ..sort((a, b) => a.pickOrder!.compareTo(b.pickOrder!));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultTitle),
        automaticallyImplyLeading: false,
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 8),
                      Icon(Icons.emoji_events_rounded,
                          size: 72, color: _winnerColor),
                      const SizedBox(height: 16),
                      Text(
                        _title(l10n),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: _winnerColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _subtitle(l10n),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _WordTile(
                              label: l10n.wordCivilians,
                              word: controller.words.civilian,
                              color: AppColors.civilian,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _WordTile(
                              label: l10n.wordUndercover,
                              word: controller.words.undercover,
                              color: AppColors.undercover,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      for (final player in players) _PlayerRow(player: player),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => _replay(context),
                  child: Text(l10n.actionReplay),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: Text(l10n.actionHome),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WordTile extends StatelessWidget {
  const _WordTile({
    required this.label,
    required this.word,
    required this.color,
  });

  final String label;
  final String word;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(height: 6),
          Text(
            word,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = roleColor(player.role);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            switch (player.role) {
              Role.civilian => Icons.shield_rounded,
              Role.undercover => Icons.theater_comedy_rounded,
              Role.mrWhite => Icons.help_outline_rounded,
            },
            color: color,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.displayName(l10n),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                decoration: player.isAlive ? null : TextDecoration.lineThrough,
                color: player.isAlive ? Colors.white : AppColors.muted,
              ),
            ),
          ),
          Text(player.role.label(l10n),
              style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }
}
