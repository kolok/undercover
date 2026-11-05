import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../l10n/locale_controller.dart';
import '../theme.dart';
import '../widgets/theater_mask_logo.dart';
import 'setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => _showLanguages(context),
                    icon: const Icon(Icons.language_rounded),
                    color: AppColors.muted,
                    tooltip: l10n.languageTitle,
                  ),
                ),
                const Spacer(flex: 2),
                const Center(
                  child: TheaterMaskLogo(color: AppColors.primary, size: 104),
                ),
                const SizedBox(height: 28),
                Text(
                  l10n.appTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.homeTagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, height: 1.5),
                ),
                const Spacer(flex: 3),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SetupScreen()),
                  ),
                  child: Text(l10n.homeStart),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _showRules(context),
                  child: Text(
                    l10n.homeRules,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context, Widget child) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => child,
    );
  }

  void _showRules(BuildContext context) =>
      _showSheet(context, const _RulesSheet());

  void _showLanguages(BuildContext context) =>
      _showSheet(context, _LanguageSheet(controller: LocaleScope.of(context)));
}

class _RulesSheet extends StatelessWidget {
  const _RulesSheet();

  /// Les quatre sections des règles, dans l'ordre d'affichage.
  static List<(String, String)> _sections(AppLocalizations l10n) => [
    (l10n.rulesSetupTitle, l10n.rulesSetupBody),
    (l10n.rulesFlowTitle, l10n.rulesFlowBody),
    (l10n.rulesMrWhiteTitle, l10n.rulesMrWhiteBody),
    (l10n.rulesVictoryTitle, l10n.rulesVictoryBody),
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
              for (final (title, body) in _sections(context.l10n)) ...[
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(color: AppColors.muted, height: 1.5),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Choix de la langue : celle du téléphone, ou l'une des langues traduites.
class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.controller});

  final LocaleController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = controller.locale?.languageCode;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.languageTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            _LanguageTile(
              label: l10n.languageSystem,
              selected: selected == null,
              onTap: () => _choose(context, null),
            ),
            for (final locale in LocaleController.selectableLocales)
              _LanguageTile(
                label:
                    LocaleController.languageNames[locale.languageCode] ??
                    locale.languageCode,
                selected: selected == locale.languageCode,
                onTap: () => _choose(context, locale),
              ),
          ],
        ),
      ),
    );
  }

  void _choose(BuildContext context, Locale? locale) {
    controller.setLocale(locale);
    Navigator.of(context).pop();
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          color: selected ? AppColors.primary : Colors.white,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}
