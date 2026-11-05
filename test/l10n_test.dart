import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undercover/data/word_bank.dart';
import 'package:undercover/l10n/l10n.dart';
import 'package:undercover/l10n/locale_controller.dart';
import 'package:undercover/main.dart';
import 'package:undercover/widgets/game_heading.dart';

/// Les langues traduites, avec le texte du bouton de l'accueil qui sert de
/// témoin que la bonne traduction est chargée.
const _startButton = {
  'fr': 'Démarrer la partie',
  'en': 'Start the game',
  'de': 'Spiel starten',
  'es': 'Empezar la partida',
  'it': 'Inizia la partita',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Listes de mots', () {
    for (final language in WordBank.supportedLanguages) {
      test('$language : 500 paires exploitables', () async {
        final pairs = await WordBank().load(language);
        expect(pairs, hasLength(500));
        for (final pair in pairs) {
          expect(pair.civilian.trim(), isNotEmpty);
          expect(pair.undercover.trim(), isNotEmpty);
          expect(pair.civilian.toLowerCase(),
              isNot(pair.undercover.toLowerCase()),
              reason: 'les deux camps doivent avoir des mots différents');
        }
      });
    }

    test('une langue sans liste retombe sur l\'anglais', () async {
      final bank = WordBank();
      expect(await bank.load('pt'), await bank.load('en'));
    });
  });

  group('Traductions', () {
    for (final entry in _startButton.entries) {
      testWidgets('${entry.key} : l\'accueil est traduit', (tester) async {
        await tester.pumpWidget(UndercoverApp(
          locales: LocaleController(initialLocale: Locale(entry.key)),
        ));
        expect(find.text(entry.value), findsOneWidget);
      });
    }

    testWidgets('une langue inconnue retombe sur l\'anglais', (tester) async {
      await tester.pumpWidget(UndercoverApp(
        locales: LocaleController(initialLocale: const Locale('pt')),
      ));
      expect(find.text(_startButton['en']!), findsOneWidget);
    });

    testWidgets('toutes les consignes gardent le jeton du nom',
        (tester) async {
      for (final locale in LocaleController.selectableLocales) {
        late AppLocalizations l10n;
        await tester.pumpWidget(MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(builder: (context) {
            l10n = context.l10n;
            return const SizedBox.shrink();
          }),
        ));
        const token = GameHeading.namePlaceholder;
        expect(l10n.distributionNextNamed(token), contains(token),
            reason: '${locale.languageCode} : le nom doit rester repérable');
        expect(l10n.roundSpeakingHint(token), contains(token),
            reason: '${locale.languageCode} : le nom doit rester repérable');
      }
    });
  });
}
