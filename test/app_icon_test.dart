import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undercover/theme.dart';
import 'package:undercover/widgets/theater_mask_logo.dart';

/// Les sources de l'icône d'application sont rendues depuis le logo lui-même :
/// ce test les compare aux fichiers de `assets/icon/`, et sert aussi à les
/// régénérer quand le dessin change.
///
/// 1. flutter test --update-goldens test/app_icon_test.dart
/// 2. dart run flutter_launcher_icons
void main() {
  /// Rend le logo sur une surface carrée de 1024x1024, taille attendue par
  /// les générateurs d'icônes Android et iOS.
  Future<void> pumpIconSurface(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(child);
  }

  testWidgets('icône complète', (tester) async {
    await pumpIconSurface(
      tester,
      const ColoredBox(
        color: AppColors.background,
        child: Center(
          child: TheaterMaskLogo(color: AppColors.primary, size: 720),
        ),
      ),
    );
    await expectLater(
      find.byType(ColoredBox),
      matchesGoldenFile('../assets/icon/app_icon.png'),
    );
  });

  testWidgets('calque avant de l\'icône adaptative Android', (tester) async {
    // Android applique un inset de 16 % à ce calque : le masque est agrandi
    // d'autant pour occuper au final ~55 % de l'icône, dans la zone sûre.
    await pumpIconSurface(
      tester,
      const Center(
        child: TheaterMaskLogo(color: AppColors.primary, size: 830),
      ),
    );
    await expectLater(
      find.byType(Center),
      matchesGoldenFile('../assets/icon/app_icon_foreground.png'),
    );
  });
}
