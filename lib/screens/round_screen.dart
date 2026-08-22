import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../models/player.dart';
import '../theme.dart';
import '../widgets/game_heading.dart';
import '../widgets/player_card.dart';
import '../widgets/quit_guard.dart';
import 'elimination_screen.dart';
import 'result_screen.dart';

/// Écran « Tour de table » : ordre de passage puis vote d'élimination.
class RoundScreen extends StatefulWidget {
  const RoundScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends State<RoundScreen> {
  GameController get _game => widget.controller;

  Future<void> _confirmElimination(Player player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Éliminer ${player.displayName} ?'),
        content: const Text(
          'Son rôle sera révélé, mais pas son mot.',
          style: TextStyle(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Éliminer',
                style: TextStyle(color: AppColors.undercover)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final navigator = Navigator.of(context);
    _game.eliminate(player.cardId);
    await navigator.push<void>(
      MaterialPageRoute(
        builder: (_) => EliminationScreen(controller: _game, player: player),
      ),
    );
    if (!mounted) return;

    if (_game.winner != null) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => ResultScreen(controller: _game)),
      );
    } else {
      _game.startNextRound();
    }
  }

  @override
  Widget build(BuildContext context) {
    return QuitGuard(
      child: Scaffold(
        appBar: AppBar(title: const Text('TOUR DE TABLE')),
        body: AppBackground(
          child: SafeArea(
            child: ListenableBuilder(
              listenable: _game,
              builder: (context, _) {
                final voting = _game.phase == GamePhase.voting;
                final order = _game.speakingOrder;
                final starter = _game.firstSpeaker?.displayName ?? '';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      GameHeading(
                        instruction: voting
                            ? 'Qui est éliminé ?'
                            : 'Manche ${_game.roundNumber}',
                        highlight: starter,
                        subtitle: voting
                            ? 'Après le vote, touchez la carte du joueur éliminé.'
                            : '${GameHeading.namePlaceholder} commence, puis '
                                'chacun donne son indice dans l\'ordre.',
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
                          itemCount: order.length,
                          itemBuilder: (context, index) {
                            final player = order[index];
                            return PlayerCard(
                              player: player,
                              orderLabel: '${index + 1}',
                              highlighted: !voting && index == 0,
                              onTap: voting
                                  ? () => _confirmElimination(player)
                                  : null,
                            );
                          },
                        ),
                      ),
                      if (!voting)
                        FilledButton(
                          onPressed: _game.startVote,
                          child: const Text('Finir le tour'),
                        ),
                      if (voting) _EliminatedRecap(controller: _game),
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

/// Rappel des joueurs déjà éliminés et de leur rôle.
class _EliminatedRecap extends StatelessWidget {
  const _EliminatedRecap({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final eliminated = controller.cards.where((p) => !p.isAlive).toList();
    if (eliminated.isEmpty) return const SizedBox.shrink();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final player in eliminated)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: roleColor(player.role).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '${player.displayName} · ${player.role.label}',
              style: TextStyle(fontSize: 12, color: roleColor(player.role)),
            ),
          ),
      ],
    );
  }
}
