import 'dart:math';

import 'package:flutter/material.dart';

import '../data/word_bank.dart';
import '../game/game_controller.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import 'distribution_screen.dart';

/// Écran « Nombre de joueurs » : choix des effectifs de chaque camp.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, this.initialSettings});

  /// Configuration à pré-remplir (utilisé quand on relance une partie).
  final GameSettings? initialSettings;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late GameSettings _settings = widget.initialSettings ??
      const GameSettings(playerCount: 6, undercoverCount: 1, mrWhiteCount: 1);

  int get _maxImpostors => GameSettings.maxImpostorsFor(_settings.playerCount);

  int get _maxUndercover => min(GameSettings.maxUndercover, _maxImpostors);

  int get _maxMrWhite =>
      min(GameSettings.maxMrWhite, _maxImpostors - _settings.undercoverCount);

  void _update(GameSettings next) => setState(() => _settings = next);

  /// La liste de mots est lue au lancement de la partie, dans la langue
  /// courante : c'est le seul moment où l'application touche au disque.
  Future<void> _play() async {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final navigator = Navigator.of(context);
    final pairs = await wordBank.load(language);
    if (!mounted) return;
    navigator.push(
      MaterialPageRoute(
        builder: (_) => DistributionScreen(
          controller: GameController(
            _settings,
            wordPairs: pairs,
            defaultPlayerName: l10n.defaultPlayerName,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupTitle)),
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
                      _CounterTile(
                        label: l10n.setupPlayers,
                        icon: Icons.groups_rounded,
                        value: _settings.playerCount,
                        min: GameSettings.minPlayers,
                        max: GameSettings.maxPlayers,
                        color: AppColors.primary,
                        onChanged: (v) =>
                            _update(_settings.copyWith(playerCount: v)),
                      ),
                      const SizedBox(height: 14),
                      _CounterTile(
                        label: l10n.roleUndercover,
                        icon: Icons.theater_comedy_rounded,
                        value: _settings.undercoverCount,
                        min: 1,
                        max: _maxUndercover,
                        color: AppColors.undercover,
                        onChanged: (v) =>
                            _update(_settings.copyWith(undercoverCount: v)),
                      ),
                      const SizedBox(height: 14),
                      _CounterTile(
                        label: l10n.roleMrWhite,
                        icon: Icons.help_outline_rounded,
                        value: _settings.mrWhiteCount,
                        min: 0,
                        max: _maxMrWhite,
                        color: AppColors.mrWhite,
                        onChanged: (v) =>
                            _update(_settings.copyWith(mrWhiteCount: v)),
                      ),
                      const SizedBox(height: 24),
                      _CivilianSummary(settings: _settings),
                      const SizedBox(height: 12),
                      Text(
                        l10n.setupHint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: _play,
                  child: Text(l10n.setupPlay),
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

class _CounterTile extends StatelessWidget {
  const _CounterTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final int value;
  final int min;
  final int max;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                Text(context.l10n.setupRange(min, max),
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          _RoundIconButton(
            icon: Icons.remove_rounded,
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 46,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
          _RoundIconButton(
            icon: Icons.add_rounded,
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surfaceHigh.withValues(alpha: enabled ? 1 : 0.4),
        foregroundColor: enabled ? Colors.white : AppColors.muted,
      ),
    );
  }
}

class _CivilianSummary extends StatelessWidget {
  const _CivilianSummary({required this.settings});

  final GameSettings settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.civilian.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.civilian.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            '${settings.civilianCount}',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.civilian,
            ),
          ),
          Text(context.l10n.setupCivilians,
              style: const TextStyle(
                  color: AppColors.civilian, letterSpacing: 1.5)),
        ],
      ),
    );
  }
}
