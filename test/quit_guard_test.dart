import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undercover/l10n/l10n.dart';
import 'package:undercover/l10n/locale_controller.dart';
import 'package:undercover/main.dart';
import 'package:undercover/theme.dart';
import 'package:undercover/widgets/quit_guard.dart';

UndercoverApp frenchApp() =>
    UndercoverApp(locales: LocaleController(initialLocale: const Locale('fr')));

Future<void> openDistribution(WidgetTester tester) async {
  await tester.pumpWidget(frenchApp());
  await tester.tap(find.text('Démarrer la partie'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Jouer'));
  await tester.pumpAndSettle();
  expect(find.text('JEU'), findsOneWidget);
}

void main() {
  testWidgets('confirmQuit : Continuer garde la partie', (tester) async {
    var quit = true;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              quit = await confirmQuit(context);
            },
            child: const Text('Ouvrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    expect(find.text('Quitter la partie ?'), findsOneWidget);

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(quit, isFalse);
  });

  testWidgets('confirmQuit : Quitter confirme l\'abandon', (tester) async {
    var quit = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              quit = await confirmQuit(context);
            },
            child: const Text('Ouvrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quitter'));
    await tester.pumpAndSettle();
    expect(quit, isTrue);
  });

  testWidgets(
    'QuitGuard demande confirmation avant de quitter la distribution',
    (tester) async {
      await openDistribution(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Quitter la partie ?'), findsOneWidget);

      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      expect(find.text('JEU'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quitter'));
      await tester.pumpAndSettle();
      expect(find.text('NOMBRE DE JOUEURS'), findsOneWidget);
    },
  );
}
