import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(widget.player.displayName.toUpperCase())),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Personne d\'autre ne doit voir cet écran.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
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
                      child: _revealed ? _buildSecret() : _buildHidden(),
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _revealed
                      ? () => Navigator.of(context).pop()
                      : null,
                  child: const Text('J\'ai vu, joueur suivant'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHidden() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.touch_app_rounded, size: 52, color: AppColors.primary),
        SizedBox(height: 16),
        Text(
          'Appuie pour découvrir\nton mot secret',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildSecret() {
    if (_isMrWhite) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.help_outline_rounded, size: 52, color: AppColors.mrWhite),
          SizedBox(height: 16),
          Text(
            'Tu es Mr White',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.mrWhite,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Tu n\'as pas de mot secret.\nÉcoute les autres et improvise.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, height: 1.5),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Ton mot secret',
            style: TextStyle(color: AppColors.muted, letterSpacing: 1.5)),
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
