import 'package:flutter/material.dart';

import '../game/game_controller.dart';
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('ÉLIMINATION'), automaticallyImplyLeading: false),
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: switch (_step) {
                _Step.reveal => _buildReveal(),
                _Step.guess => _buildGuess(),
                _Step.guessResult => _buildGuessResult(),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReveal() {
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
          _player.displayName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'était ${_player.role == Role.mrWhite ? '' : 'un '}${_player.role.label}',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 16),
        const Text(
          'Son mot reste secret.',
          style: TextStyle(color: AppColors.muted),
        ),
        const Spacer(),
        if (_player.role == Role.mrWhite)
          FilledButton(
            onPressed: () => setState(() => _step = _Step.guess),
            child: const Text('Deviner le mot des civils'),
          )
        else
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuer'),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGuess() {
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
                  '${_player.displayName}, dernière chance',
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Quel est le mot des civils ? Si tu trouves, tu gagnes la partie.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, height: 1.5),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _guessController,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  style:
                      const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(hintText: 'Ta proposition'),
                  onSubmitted: (_) => _submitGuess(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        FilledButton(
          onPressed: _submitGuess,
          child: const Text('Valider ma proposition'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGuessResult() {
    final color = _guessedRight ? AppColors.civilian : AppColors.undercover;
    return Column(
      children: [
        const Spacer(),
        Icon(_guessedRight ? Icons.celebration_rounded : Icons.close_rounded,
            size: 72, color: color),
        const SizedBox(height: 24),
        Text(
          _guessedRight ? 'Trouvé !' : 'Raté !',
          style: TextStyle(
              fontSize: 32, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 16),
        if (_guessedRight) ...[
          const Text('Le mot des civils était bien',
              style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 8),
          Text(
            widget.controller.words.civilian,
            style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text('${_player.displayName} remporte la partie.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted)),
        ] else
          Text(
            'Le mot des civils reste secret.\n'
            '${_player.displayName} est éliminé.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, height: 1.5),
          ),
        const Spacer(),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Continuer'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
