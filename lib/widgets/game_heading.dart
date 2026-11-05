import 'package:flutter/material.dart';

import '../theme.dart';

/// En-tête des écrans de jeu : une consigne bien lisible, précédée d'une
/// marge, dans laquelle le nom du joueur concerné ressort en plus grand.
class GameHeading extends StatelessWidget {
  const GameHeading({
    super.key,
    required this.instruction,
    this.highlight,
    this.subtitle,
  });

  /// La consigne affichée en grand. Le jeton [namePlaceholder] y est remplacé
  /// par [highlight].
  final String instruction;

  /// Nom du joueur concerné, écrit encore plus gros que la ligne qui le porte.
  final String? highlight;

  /// Précision affichée en dessous, en plus discret. Accepte aussi le jeton.
  final String? subtitle;

  /// Marque la place du nom dans une consigne. Un jeton plutôt qu'une
  /// recherche du nom dans le texte : un joueur qui s'appelle « de » ne doit
  /// pas voir le « de » de « Au tour de » grossir à sa place.
  static const namePlaceholder = '{nom}';

  static const _instructionStyle = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w800,
    height: 1.35,
  );

  static const _subtitleStyle = TextStyle(
    color: AppColors.muted,
    fontSize: 16,
    height: 1.4,
  );

  static TextStyle _nameStyle(double fontSize) => TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
  );

  /// Remplace chaque jeton par le nom, écrit en plus gros.
  List<InlineSpan> _spans(String text, double nameSize) {
    final parts = text.split(namePlaceholder);
    final name = highlight ?? '';
    return [
      for (var i = 0; i < parts.length; i++) ...[
        if (i > 0) TextSpan(text: name, style: _nameStyle(nameSize)),
        if (parts[i].isNotEmpty) TextSpan(text: parts[i]),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 4),
      child: Column(
        children: [
          Text.rich(
            TextSpan(children: _spans(instruction, 30)),
            textAlign: TextAlign.center,
            style: _instructionStyle,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(children: _spans(subtitle!, 22)),
              textAlign: TextAlign.center,
              style: _subtitleStyle,
            ),
          ],
        ],
      ),
    );
  }
}
