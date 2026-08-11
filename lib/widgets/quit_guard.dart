import 'package:flutter/material.dart';

import '../theme.dart';

/// Demande confirmation avant de quitter une partie en cours.
class QuitGuard extends StatelessWidget {
  const QuitGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await confirmQuit(context)) {
          navigator.pop();
        }
      },
      child: child,
    );
  }
}

Future<bool> confirmQuit(BuildContext context) async {
  final quit = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Quitter la partie ?'),
      content: const Text(
        'La partie en cours sera perdue.',
        style: TextStyle(color: AppColors.muted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Continuer'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Quitter',
              style: TextStyle(color: AppColors.undercover)),
        ),
      ],
    ),
  );
  return quit ?? false;
}
