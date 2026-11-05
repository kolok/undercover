import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme.dart';

/// Écran joueur 1 : saisie du nom, avec une proposition par défaut.
class PlayerNameScreen extends StatefulWidget {
  const PlayerNameScreen({
    super.key,
    required this.suggestedName,
    this.takenNames = const [],
  });

  final String suggestedName;

  /// Noms des joueurs déjà installés : deux joueurs ne peuvent pas les partager.
  final List<String> takenNames;

  @override
  State<PlayerNameScreen> createState() => _PlayerNameScreenState();
}

class _PlayerNameScreenState extends State<PlayerNameScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.suggestedName,
  );

  /// Message d'erreur affiché sous le champ, `null` tant que tout va bien.
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isTaken(String name) {
    final candidate = name.toLowerCase();
    return widget.takenNames.any((n) => n.trim().toLowerCase() == candidate);
  }

  void _validate() {
    final typed = _controller.text.trim();
    final name = typed.isEmpty ? widget.suggestedName : typed;
    if (_isTaken(name)) {
      setState(() => _error = context.l10n.nameTaken);
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nameTitle)),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        const Icon(
                          Icons.badge_rounded,
                          size: 56,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.namePrompt,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _controller,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          maxLength: 14,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            errorText: _error,
                            errorStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onChanged: (_) {
                            if (_error != null) setState(() => _error = null);
                          },
                          onSubmitted: (_) => _validate(),
                        ),
                      ],
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: _validate,
                  child: Text(l10n.nameSubmit),
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
