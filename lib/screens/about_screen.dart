import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';
import '../theme.dart';

/// Fiche de l'application : Android l'ouvre dans l'app Play Store.
final _playStoreUrl = Uri.parse(
  'https://play.google.com/store/apps/details?id=com.kolok.undercover',
);

/// Écran « À propos » : l'esprit de l'application et comment la soutenir.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const textStyle = TextStyle(color: AppColors.muted, height: 1.5, fontSize: 20);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        Text(l10n.aboutBody, style: textStyle),
                        const SizedBox(height: 20),
                        Text(l10n.aboutSupport, style: textStyle),
                      ],
                    ),
                  ),
                ),
                // Pas de lien vers le Play Store sur les autres plateformes.
                if (defaultTargetPlatform == TargetPlatform.android)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: FilledButton.icon(
                      onPressed: () => launchUrl(
                        _playStoreUrl,
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.star_rounded),
                      label: Text(l10n.aboutRate),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
