import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../l10n/l10n.dart';
import '../models/player.dart';
import '../theme.dart';

enum _Step { reveal, guess, guessResult }

/// Révélation du rôle du joueur éliminé (jamais son mot), suivie de la
/// dernière chance de Mr White : deviner le mot des civils.
class EliminationScreen extends StatefulWidget {
  const EliminationScreen({
    super.key,
    required this.controller,
    required this.player,
  });

  final GameController controller;
  final Player player;

  @override
  State<EliminationScreen> createState() => _EliminationScreenState();
}

class _EliminationScreenState extends State<EliminationScreen> {
  final _guessController = TextEditingController();
  _Step _step = _Step.reveal;
  bool _guessedRight = false;

  Player get _player => widget.player;

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  void _submitGuess() {
    final guess = _guessController.text.trim();
    if (guess.isEmpty) return;
    setState(() {
      _guessedRight = widget.controller.submitMrWhiteGuess(guess);
      _step = _Step.guessResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.eliminationTitle),
          automaticallyImplyLeading: false,
        ),
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: switch (_step) {
                _Step.reveal => _buildReveal(l10n),
                _Step.guess => _buildGuess(l10n),
                _Step.guessResult => _buildGuessResult(l10n),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReveal(AppLocalizations l10n) {
    final color = roleColor(_player.role);
    return Column(
      children: [
        const Spacer(),
        Icon(
          switch (_player.role) {
            Role.civilian => Icons.shield_rounded,
            Role.undercover => Icons.theater_comedy_rounded,
            Role.mrWhite => Icons.help_outline_rounded,
          },
          size: 72,
          color: color,
        ),
        const SizedBox(height: 24),
        Text(
          _player.displayName(l10n),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          switch (_player.role) {
            Role.civilian => l10n.eliminationWasCivilian,
            Role.undercover => l10n.eliminationWasUndercover,
            Role.mrWhite => l10n.eliminationWasMrWhite,
          },
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.eliminationWordSecret,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted),
        ),
        const Spacer(),
        if (_player.role == Role.mrWhite)
          FilledButton(
            onPressed: () => setState(() => _step = _Step.guess),
            child: Text(l10n.eliminationGuessCta),
          )
        else
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionContinue),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGuess(AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.psychology_alt_rounded,
                    size: 64, color: AppColors.mrWhite),
                const SizedBox(height: 20),
                Text(
                  l10n.guessLastChance(_player.displayName(l10n)),
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.guessPrompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, height: 1.5),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _guessController,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  style:
                      const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  decoration:
                      InputDecoration(hintText: l10n.guessFieldHint),
                  onSubmitted: (_) => _submitGuess(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        FilledButton(
          onPressed: _submitGuess,
          child: Text(l10n.guessSubmit),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGuessResult(AppLocalizations l10n) {
    final color = _guessedRight ? AppColors.civilian : AppColors.undercover;
    return Column(
      children: [
        const Spacer(),
        Icon(_guessedRight ? Icons.celebration_rounded : Icons.close_rounded,
            size: 72, color: color),
        const SizedBox(height: 24),
        Text(
          _guessedRight ? l10n.guessRight : l10n.guessWrong,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 32, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 16),
        if (_guessedRight) ...[
          Text(l10n.guessWordWas,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 8),
          Text(
            widget.controller.words.civilian,
            style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(l10n.guessWinner(_player.displayName(l10n)),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted)),
        ] else
          Text(
            l10n.guessLost(_player.displayName(l10n)),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, height: 1.5),
          ),
        const Spacer(),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionContinue),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
