import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/player.dart';
import '../theme.dart';

/// Écran joueur 2 : le mot secret, ou l'annonce du rôle Mr White.
///
/// Le mot n'apparaît qu'après un appui, pour éviter de le dévoiler quand le
/// téléphone change de mains.
class PlayerWordScreen extends StatefulWidget {
  const PlayerWordScreen({
    super.key,
    required this.player,
    required this.secretWord,
  });

  final Player player;

  /// `null` pour Mr White, qui n'a pas de mot.
  final String? secretWord;

  @override
  State<PlayerWordScreen> createState() => _PlayerWordScreenState();
}

class _PlayerWordScreenState extends State<PlayerWordScreen> {
  bool _revealed = false;

  bool get _isMrWhite => widget.secretWord == null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.player.displayName(l10n).toUpperCase()),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  l10n.wordPrivacy,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const Spacer(),
                Expanded(
                  flex: 6,
                  child: GestureDetector(
                    onTap: () => setState(() => _revealed = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _revealed
                            ? AppColors.surface
                            : AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: _revealed && _isMrWhite
                              ? AppColors.mrWhite
                              : AppColors.primary.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(24),
                      child: _revealed
                          ? _buildSecret(l10n)
                          : _buildHidden(l10n),
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _revealed
                      ? () => Navigator.of(context).pop()
                      : null,
                  child: Text(l10n.wordSeen),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHidden(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.touch_app_rounded, size: 52, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          l10n.wordTapToReveal,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildSecret(AppLocalizations l10n) {
    if (_isMrWhite) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.help_outline_rounded,
            size: 52,
            color: AppColors.mrWhite,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.wordMrWhiteTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.mrWhite,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.wordMrWhiteBody,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, height: 1.5),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.wordSecretLabel,
          style: const TextStyle(color: AppColors.muted, letterSpacing: 1.5),
        ),
        const SizedBox(height: 14),
        Text(
          widget.secretWord!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
