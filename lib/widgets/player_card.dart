import 'package:flutter/material.dart';

import '../models/player.dart';
import '../theme.dart';

/// Carte d'un joueur, affichée face cachée puis face visible.
///
/// Selon l'état du joueur elle montre un dos de carte, le nom de son
/// propriétaire, son ordre de passage ou son rôle une fois éliminé.
class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.player,
    this.onTap,
    this.orderLabel,
    this.highlighted = false,
  });

  final Player player;
  final VoidCallback? onTap;

  /// Numéro de passage affiché dans le coin (tour de table).
  final String? orderLabel;

  /// Met la carte en avant (premier joueur à parler).
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final eliminated = !player.isAlive;
    final revealedRole = player.isRevealed ? player.role : null;
    final accent = revealedRole != null ? roleColor(revealedRole) : AppColors.primary;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: eliminated ? 0.55 : 1,
      child: Material(
        color: player.isTaken ? AppColors.surface : AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: highlighted
                    ? AppColors.primary
                    : accent.withValues(alpha: revealedRole != null ? 0.7 : 0.15),
                width: highlighted ? 2.5 : 1.5,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                Center(child: _buildFace(context, revealedRole)),
                if (orderLabel != null)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: highlighted
                            ? AppColors.primary
                            : AppColors.surfaceHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        orderLabel!,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                if (eliminated)
                  const Align(
                    alignment: Alignment.topRight,
                    child: Icon(Icons.close_rounded,
                        color: AppColors.undercover, size: 20),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFace(BuildContext context, Role? revealedRole) {
    if (!player.isTaken) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.question_mark_rounded,
              size: 30, color: AppColors.primary),
          SizedBox(height: 6),
          Text('Libre',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          revealedRole == null
              ? Icons.person_rounded
              : switch (revealedRole) {
                  Role.civilian => Icons.shield_rounded,
                  Role.undercover => Icons.theater_comedy_rounded,
                  Role.mrWhite => Icons.help_outline_rounded,
                },
          size: 28,
          color: revealedRole == null ? Colors.white70 : roleColor(revealedRole),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            player.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        if (revealedRole != null)
          Text(
            revealedRole.label,
            style: TextStyle(
                fontSize: 11,
                color: roleColor(revealedRole),
                fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}
