import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undercover/game/game_controller.dart';
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

/// Génère les visuels de la fiche Google Play dans `store/`.
///
/// Ce fichier n'est pas un test de régression (il ne finit pas par `_test.dart`
/// et n'est donc pas exécuté par `flutter test`). Il se lance à la demande :
///
///   flutter test --update-goldens test/store_assets_generator.dart
void main() {
  const words = [WordPair('Citron', 'Orange')];

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
  GameController buildGame({int claimed = 6}) {
    final game = GameController(
      const GameSettings(playerCount: 6, undercoverCount: 1, mrWhiteCount: 1),
      random: Random(3),
      wordPairs: words,
    );
    const names = ['Nico', 'Léa', 'Sam', 'Jules', 'Inès', 'Théo'];
    for (var i = 0; i < claimed; i++) {
      game.claimCard(i, names[i]);
    }
    return game;
  }

  Future<void> capture(
    WidgetTester tester,
    Widget home,
    String name, {
    Size size = const Size(1080, 1920),
    double pixelRatio = 3,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = pixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _storeTheme(),
        home: home,
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../store/$name.png'),
    );
  }

  testWidgets('01 accueil', (tester) async {
    await capture(tester, const HomeScreen(), '01-accueil');
  });

  testWidgets('02 nombre de joueurs', (tester) async {
    await capture(tester, const SetupScreen(), '02-joueurs');
  });

  testWidgets('03 distribution des cartes', (tester) async {
    await capture(
      tester,
      DistributionScreen(controller: buildGame(claimed: 3)),
      '03-cartes',
    );
  });

  testWidgets('04 mot secret', (tester) async {
    final game = buildGame();
    final player = game.cards.firstWhere((p) => p.isCivilian);
    await capture(
      tester,
      PlayerWordScreen(player: player, secretWord: game.secretWordFor(player)),
      '04-mot-secret',
    );
    // Le mot n'apparaît qu'après un appui sur la carte.
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../store/04-mot-secret.png'),
    );
  });

  testWidgets('05 tour de table', (tester) async {
    final game = buildGame()..startRoundTable();
    await capture(tester, RoundScreen(controller: game), '05-tour-de-table');
  });

  testWidgets('06 fin de partie', (tester) async {
    final game = buildGame()..startRoundTable();
    game.startVote();
    for (final player in game.cards.where((p) => p.isImpostor).toList()) {
      game.eliminate(player.cardId);
      if (player.role == Role.mrWhite) game.submitMrWhiteGuess('banane');
    }
    await capture(tester, ResultScreen(controller: game), '06-victoire');
  });

  testWidgets('graphique de présentation', (tester) async {
    await capture(
      tester,
      const _FeatureGraphic(),
      'feature-graphic',
      size: const Size(1024, 500),
      pixelRatio: 1,
    );
  });
}

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
  const _FeatureGraphic();

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
                  'Un seul téléphone.\nUn seul mot qui ne colle pas.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 26,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.72),
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
