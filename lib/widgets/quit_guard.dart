import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
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
  final l10n = context.l10n;
  final quit = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(l10n.quitTitle),
      content: Text(
        l10n.quitBody,
        style: const TextStyle(color: AppColors.muted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.actionContinue),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            l10n.actionQuit,
            style: const TextStyle(color: AppColors.undercover),
          ),
        ),
      ],
    ),
  );
  return quit ?? false;
}
