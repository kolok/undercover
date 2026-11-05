import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../l10n/l10n.dart';
import '../models/player.dart';
import '../theme.dart';
import '../widgets/game_heading.dart';
import '../widgets/player_card.dart';
import '../widgets/quit_guard.dart';
import 'player_name_screen.dart';
import 'player_word_screen.dart';
import 'round_screen.dart';

/// Écran « Jeu » : les cartes face cachée, une par joueur.
///
/// Le téléphone passe de main en main ; chaque joueur choisit une carte
/// libre, saisit son nom puis découvre son mot secret.
class DistributionScreen extends StatefulWidget {
  const DistributionScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {
  GameController get _game => widget.controller;

  Future<void> _pickCard(Player card) async {
    final navigator = Navigator.of(context);
    // Avec une équipe reprise de la partie précédente, l'application sait déjà
    // qui joue : on saute la saisie du nom.
    var name = _game.nextPlayerName;
    if (name == null) {
      name = await navigator.push<String>(
        MaterialPageRoute(
          builder: (_) => PlayerNameScreen(
            suggestedName: _game.suggestedName,
            takenNames: _game.takenNames,
          ),
        ),
      );
      if (name == null || !mounted) return;
    }

    _game.claimCard(card.cardId, name);
    await navigator.push<void>(
      MaterialPageRoute(
        builder: (_) => PlayerWordScreen(
          player: card,
          secretWord: _game.secretWordFor(card),
        ),
      ),
    );
  }

  void _startRoundTable() {
    _game.startRoundTable();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => RoundScreen(controller: _game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return QuitGuard(
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.gameTitle)),
        body: AppBackground(
          child: SafeArea(
            child: ListenableBuilder(
              listenable: _game,
              builder: (context, _) {
                final l10n = context.l10n;
                final done = _game.isDistributionComplete;
                final next = _game.nextPlayerName;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      GameHeading(
                        instruction: done
                            ? l10n.distributionDone
                            : next == null
                                ? l10n.distributionNextAnyone
                                : l10n.distributionNextNamed(
                                    GameHeading.namePlaceholder),
                        highlight: next,
                        subtitle: l10n.distributionProgress(
                          _game.takenCardCount,
                          _game.settings.playerCount,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.only(bottom: 12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: _game.cards.length,
                          itemBuilder: (context, index) {
                            final card = _game.cards[index];
                            return PlayerCard(
                              player: card,
                              onTap: card.isTaken ? null : () => _pickCard(card),
                            );
                          },
                        ),
                      ),
                      if (done)
                        FilledButton(
                          onPressed: _startRoundTable,
                          child: Text(l10n.distributionStart),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
