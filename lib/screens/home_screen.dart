import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/theater_mask_logo.dart';
import 'setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                const Center(
                  child: TheaterMaskLogo(color: AppColors.primary, size: 104),
                ),
                const SizedBox(height: 28),
                Text(
                  'UNDERCOVER',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Un seul téléphone, trois camps,\nun seul mot qui ne colle pas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, height: 1.5),
                ),
                const Spacer(flex: 3),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SetupScreen()),
                  ),
                  child: const Text('Démarrer la partie'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _showRules(context),
                  child: const Text('Règles du jeu',
                      style: TextStyle(color: AppColors.muted)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRules(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const _RulesSheet(),
    );
  }
}

class _RulesSheet extends StatelessWidget {
  const _RulesSheet();

  static const _sections = [
    (
      'Mise en place',
      'Chaque joueur reçoit secrètement un mot. Les civils ont tous le même, '
          'les undercover en ont un proche mais différent. Mr White, lui, '
          'n\'a aucun mot. Personne ne sait s\'il est civil ou undercover.',
    ),
    (
      'Déroulement',
      'À tour de rôle, chacun donne un indice décrivant son mot sans le dire. '
          'Puis tout le monde vote pour éliminer un joueur : son rôle est '
          'révélé, mais jamais son mot.',
    ),
    (
      'Mr White',
      'Sans mot, il improvise. S\'il est éliminé, il a une dernière chance : '
          'deviner le mot des civils. S\'il trouve, il gagne la partie.',
    ),
    (
      'Victoire',
      'Les civils gagnent en éliminant tous les undercover et Mr White. '
          'Le camp adverse gagne s\'il ne reste plus qu\'un seul civil.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (title, body) in _sections) ...[
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: AppColors.primary,
                    )),
                const SizedBox(height: 6),
                Text(body,
                    style: const TextStyle(color: AppColors.muted, height: 1.5)),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
