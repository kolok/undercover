import 'package:flutter/material.dart';

import '../theme.dart';

/// Écran joueur 1 : saisie du nom, avec une proposition par défaut.
class PlayerNameScreen extends StatefulWidget {
  const PlayerNameScreen({super.key, required this.suggestedName});

  final String suggestedName;

  @override
  State<PlayerNameScreen> createState() => _PlayerNameScreenState();
}

class _PlayerNameScreenState extends State<PlayerNameScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.suggestedName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate() {
    final name = _controller.text.trim();
    Navigator.of(context).pop(name.isEmpty ? widget.suggestedName : name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TON NOM')),
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
                        const Icon(Icons.badge_rounded,
                            size: 56, color: AppColors.primary),
                        const SizedBox(height: 20),
                        const Text(
                          'Comment t\'appelles-tu ?',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800),
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
                              fontSize: 22, fontWeight: FontWeight.w700),
                          onSubmitted: (_) => _validate(),
                        ),
                      ],
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: _validate,
                  child: const Text('Valider'),
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
