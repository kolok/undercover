import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undercover/l10n/l10n.dart';
import 'package:undercover/models/player.dart';
import 'package:undercover/theme.dart';
import 'package:undercover/widgets/player_card.dart';

Widget frenchHost(Widget home) => MaterialApp(
  theme: buildAppTheme(),
  locale: const Locale('fr'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  testWidgets('carte libre affiche le libellé Libre', (tester) async {
    final player = Player(cardId: 0, role: Role.civilian);

    await tester.pumpWidget(
      frenchHost(
        Scaffold(
          body: Center(child: PlayerCard(player: player)),
        ),
      ),
    );

    expect(find.text('Libre'), findsOneWidget);
    expect(find.byIcon(Icons.question_mark_rounded), findsOneWidget);
  });

  testWidgets('carte prise affiche le nom du joueur', (tester) async {
    final player = Player(cardId: 0, role: Role.civilian)..name = 'Zoé';

    await tester.pumpWidget(
      frenchHost(
        Scaffold(
          body: Center(child: PlayerCard(player: player)),
        ),
      ),
    );

    expect(find.text('Zoé'), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
  });

  testWidgets('carte éliminée avec rôle révélé affiche le camp', (
    tester,
  ) async {
    final player = Player(cardId: 0, role: Role.undercover)
      ..name = 'Bob'
      ..isAlive = false
      ..isRevealed = true;

    await tester.pumpWidget(
      frenchHost(
        Scaffold(
          body: Center(child: PlayerCard(player: player)),
        ),
      ),
    );

    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Undercover'), findsOneWidget);
    expect(find.byIcon(Icons.theater_comedy_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('les trois rôles révélés ont l\'icône attendue', (tester) async {
    final roles = <Role, IconData>{
      Role.civilian: Icons.shield_rounded,
      Role.undercover: Icons.theater_comedy_rounded,
      Role.mrWhite: Icons.help_outline_rounded,
    };

    for (final entry in roles.entries) {
      final player = Player(cardId: 0, role: entry.key)
        ..name = 'J'
        ..isRevealed = true;

      await tester.pumpWidget(
        frenchHost(
          Scaffold(
            body: Center(child: PlayerCard(player: player)),
          ),
        ),
      );

      expect(find.byIcon(entry.value), findsOneWidget);
    }
  });

  testWidgets('badge d\'ordre et surbrillance', (tester) async {
    final player = Player(cardId: 0, role: Role.civilian)..name = 'Sam';

    await tester.pumpWidget(
      frenchHost(
        Scaffold(
          body: Center(
            child: PlayerCard(
              player: player,
              orderLabel: '1',
              highlighted: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('onTap est transmis', (tester) async {
    final player = Player(cardId: 0, role: Role.civilian);
    var tapped = false;

    await tester.pumpWidget(
      frenchHost(
        Scaffold(
          body: Center(
            child: PlayerCard(player: player, onTap: () => tapped = true),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    expect(tapped, isTrue);
  });
}
