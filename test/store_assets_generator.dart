import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undercover/game/game_controller.dart';
import 'package:undercover/l10n/l10n.dart';
import 'package:undercover/l10n/locale_controller.dart';
import 'package:undercover/models/player.dart';
import 'package:undercover/models/word_pair.dart';
import 'package:undercover/screens/distribution_screen.dart';
import 'package:undercover/screens/home_screen.dart';
import 'package:undercover/screens/player_word_screen.dart';
import 'package:undercover/screens/result_screen.dart';
import 'package:undercover/screens/round_screen.dart';
import 'package:undercover/screens/setup_screen.dart';
import 'package:undercover/theme.dart';
import 'package:undercover/widgets/theater_mask_logo.dart';

/// Génère les visuels de la fiche Google Play dans `store/<langue>/`, une série
/// par langue traduite.
///
/// Ce fichier n'est pas un test de régression (il ne finit pas par `_test.dart`
/// et n'est donc pas exécuté par `flutter test`). Il se lance à la demande :
///
///   flutter test --update-goldens test/store_assets_generator.dart
void main() {
  // flutter_test remplace toutes les polices par une police de test qui rend
  // des rectangles : on charge les vraies polices du SDK pour les captures.
  setUpAll(() async {
    final fontsDir = Directory(
      '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter'}'
      '/bin/cache/artifacts/material_fonts',
    );
    final roboto = [
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
      'Roboto-Black.ttf',
    ].map((name) => File('${fontsDir.path}/$name').readAsBytes()).toList();

    // « FlutterTest » est la police par défaut du binding de test : en
    // l'écrasant, tous les textes sans famille explicite passent en Roboto.
    for (final family in ['Roboto', 'FlutterTest']) {
      final loader = FontLoader(family);
      for (final font in roboto) {
        loader.addFont(font.then((bytes) => bytes.buffer.asByteData()));
      }
      await loader.load();
    }

    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${fontsDir.path}/MaterialIcons-Regular.otf',
        ).readAsBytes().then((bytes) => bytes.buffer.asByteData()),
      );
    await icons.load();
  });

  /// Partie fictive et reproductible pour peupler les écrans.
  GameController buildGame(_StoreCopy copy, {int claimed = 6}) {
    final game = GameController(
      const GameSettings(playerCount: 6, undercoverCount: 1, mrWhiteCount: 1),
      random: Random(3),
      wordPairs: [copy.words],
    );
    for (var i = 0; i < claimed; i++) {
      game.claimCard(i, copy.names[i]);
    }
    return game;
  }

  Future<void> capture(
    WidgetTester tester,
    _StoreCopy copy,
    Widget home,
    String name, {
    Size size = const Size(1080, 1920),
    double pixelRatio = 3,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = pixelRatio;
    addTearDown(tester.view.reset);
    final locale = Locale(copy.languageCode);
    await tester.pumpWidget(
      LocaleScope(
        controller: LocaleController(initialLocale: locale),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _storeTheme(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../store/${copy.languageCode}/$name.png'),
    );
  }

  for (final copy in _storeCopies) {
    group(copy.languageCode, () {
      testWidgets('01 accueil', (tester) async {
        await capture(tester, copy, const HomeScreen(), '01-accueil');
      });

      testWidgets('02 nombre de joueurs', (tester) async {
        await capture(tester, copy, const SetupScreen(), '02-joueurs');
      });

      testWidgets('03 distribution des cartes', (tester) async {
        await capture(
          tester,
          copy,
          DistributionScreen(controller: buildGame(copy, claimed: 3)),
          '03-cartes',
        );
      });

      testWidgets('04 mot secret', (tester) async {
        final game = buildGame(copy);
        final player = game.cards.firstWhere((p) => p.isCivilian);
        await capture(
          tester,
          copy,
          PlayerWordScreen(
            player: player,
            secretWord: game.secretWordFor(player),
          ),
          '04-mot-secret',
        );
        // Le mot n'apparaît qu'après un appui sur la carte.
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../store/${copy.languageCode}/04-mot-secret.png'),
        );
      });

      testWidgets('05 tour de table', (tester) async {
        final game = buildGame(copy)..startRoundTable();
        await capture(
          tester,
          copy,
          RoundScreen(controller: game),
          '05-tour-de-table',
        );
      });

      testWidgets('06 fin de partie', (tester) async {
        final game = buildGame(copy)..startRoundTable();
        game.startVote();
        for (final player in game.cards.where((p) => p.isImpostor).toList()) {
          game.eliminate(player.cardId);
          if (player.role == Role.mrWhite) game.submitMrWhiteGuess('banane');
        }
        await capture(
          tester,
          copy,
          ResultScreen(controller: game),
          '06-victoire',
        );
      });

      testWidgets('graphique de présentation', (tester) async {
        await capture(
          tester,
          copy,
          _FeatureGraphic(copy),
          'feature-graphic',
          size: const Size(1024, 500),
          pixelRatio: 1,
        );
      });
    });
  }
}

/// Ce qui change d'une langue à l'autre dans les visuels, en plus des textes de
/// l'interface : la paire de mots (tirée de la banque de chaque langue), les
/// prénoms de la partie fictive et l'accroche du graphique de présentation.
class _StoreCopy {
  const _StoreCopy({
    required this.languageCode,
    required this.words,
    required this.names,
    required this.tagline,
    required this.promise,
  });

  final String languageCode;
  final WordPair words;
  final List<String> names;
  final String tagline;
  final String promise;
}

const _storeCopies = [
  _StoreCopy(
    languageCode: 'fr',
    words: WordPair('Citron', 'Orange'),
    names: ['Nico', 'Léa', 'Sam', 'Jules', 'Inès', 'Théo'],
    tagline: 'Un seul téléphone.\nUn seul mot qui ne colle pas.',
    promise: 'Pas de pub, pas de collecte de données.',
  ),
  _StoreCopy(
    languageCode: 'en',
    words: WordPair('Lemon', 'Orange'),
    names: ['Nick', 'Emma', 'Sam', 'Jack', 'Lily', 'Theo'],
    tagline: 'One phone.\nOne word that does not fit.',
    promise: 'No ads, no data collection.',
  ),
  _StoreCopy(
    languageCode: 'de',
    words: WordPair('Zitrone', 'Orange'),
    names: ['Niko', 'Lena', 'Sam', 'Jonas', 'Mia', 'Theo'],
    tagline: 'Ein Handy.\nEin Wort, das nicht passt.',
    promise: 'Keine Werbung, keine Datenerfassung.',
  ),
  _StoreCopy(
    languageCode: 'es',
    words: WordPair('Limón', 'Naranja'),
    names: ['Nico', 'Lucía', 'Sam', 'Mateo', 'Inés', 'Hugo'],
    tagline: 'Un solo móvil.\nUna palabra que no encaja.',
    promise: 'Sin anuncios, sin recopilación de datos.',
  ),
  _StoreCopy(
    languageCode: 'it',
    words: WordPair('Limone', 'Arancia'),
    names: ['Nico', 'Giulia', 'Sam', 'Luca', 'Sofia', 'Matteo'],
    tagline: 'Un solo telefono.\nUna parola che non torna.',
    promise: 'Niente pubblicità, nessuna raccolta di dati.',
  ),
];

/// Thème de l'application, dont les styles déclarés sans famille de police
/// (titre d'AppBar, libellés de boutons) sont forcés en Roboto : sinon le
/// binding de test les rend en rectangles.
ThemeData _storeTheme() {
  final base = buildAppTheme();
  ButtonStyle withRoboto(ButtonStyle? style) =>
      (style ?? const ButtonStyle()).copyWith(
        textStyle: WidgetStateProperty.resolveWith(
          (states) => (style?.textStyle?.resolve(states) ?? const TextStyle())
              .copyWith(fontFamily: 'Roboto'),
        ),
      );

  return base.copyWith(
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
        fontFamily: 'Roboto',
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: withRoboto(base.filledButtonTheme.style),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: withRoboto(base.outlinedButtonTheme.style),
    ),
  );
}

/// Bandeau 1024x500 affiché en haut de la fiche Play.
class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic(this.copy);

  final _StoreCopy copy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF241a52), AppColors.background],
        ),
      ),
      // Sans Material englobant, Flutter souligne les textes en jaune.
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TheaterMaskLogo(color: AppColors.primary, size: 230),
            const SizedBox(width: 36),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UNDERCOVER',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  copy.tagline,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 26,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  copy.promise,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
