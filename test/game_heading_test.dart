import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undercover/theme.dart';
import 'package:undercover/widgets/game_heading.dart';

/// Le texte avant le nom, tel qu'il est écrit dans la taille normale.
String textBeforeName(WidgetTester tester, String plainText) {
  final spans = ((tester.widget<Text>(find.text(plainText)).textSpan!)
          as TextSpan)
      .children!
      .cast<TextSpan>();
  return spans.takeWhile((s) => s.style == null).map((s) => s.text).join();
}

List<TextSpan> nameSpans(WidgetTester tester, String plainText) {
  final spans =
      ((tester.widget<Text>(find.text(plainText)).textSpan!) as TextSpan)
          .children!
          .cast<TextSpan>();
  return spans.where((s) => s.style != null).toList();
}

Future<void> pumpHeading(WidgetTester tester, GameHeading heading) {
  return tester.pumpWidget(MaterialApp(
    theme: buildAppTheme(),
    home: Scaffold(body: heading),
  ));
}

void main() {
  testWidgets('le nom est écrit plus gros que le reste de la consigne',
      (tester) async {
    await pumpHeading(
      tester,
      const GameHeading(
        instruction: 'Au tour de ${GameHeading.namePlaceholder} de choisir '
            'une carte',
        highlight: 'Zoé',
      ),
    );

    const plain = 'Au tour de Zoé de choisir une carte';
    final name = nameSpans(tester, plain).single;
    expect(name.text, 'Zoé');
    expect(name.style!.color, AppColors.primary);
    expect(name.style!.fontSize,
        greaterThan(tester.widget<Text>(find.text(plain)).style!.fontSize!));
  });

  testWidgets('un joueur nommé « de » ne fait pas grossir le mauvais mot',
      (tester) async {
    await pumpHeading(
      tester,
      const GameHeading(
        instruction: 'Au tour de ${GameHeading.namePlaceholder} de choisir '
            'une carte',
        highlight: 'de',
      ),
    );

    const plain = 'Au tour de de de choisir une carte';
    expect(nameSpans(tester, plain).single.text, 'de');
    expect(textBeforeName(tester, plain), 'Au tour de ');
  });

  testWidgets('le nom est aussi mis en avant dans le sous-titre',
      (tester) async {
    await pumpHeading(
      tester,
      const GameHeading(
        instruction: 'Manche 2',
        highlight: 'Sam',
        subtitle: '${GameHeading.namePlaceholder} commence.',
      ),
    );

    expect(find.text('Manche 2'), findsOneWidget);
    expect(nameSpans(tester, 'Sam commence.').single.text, 'Sam');
  });
}
