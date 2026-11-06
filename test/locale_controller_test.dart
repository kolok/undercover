import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undercover/l10n/locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocaleController', () {
    test('restore ignore un code inconnu', () async {
      SharedPreferences.setMockInitialValues({'app_language_code': 'xx'});
      final controller = LocaleController();
      await controller.restore();
      expect(controller.locale, isNull);
    });

    test('restore charge la langue enregistrée', () async {
      SharedPreferences.setMockInitialValues({'app_language_code': 'de'});
      final controller = LocaleController();
      await controller.restore();
      expect(controller.locale?.languageCode, 'de');
    });

    test('setLocale enregistre et notifie', () async {
      final controller = LocaleController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.setLocale(const Locale('es'));

      expect(controller.locale?.languageCode, 'es');
      expect(notifications, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language_code'), 'es');
    });

    test('setLocale null efface le stockage', () async {
      SharedPreferences.setMockInitialValues({'app_language_code': 'fr'});
      final controller = LocaleController(initialLocale: const Locale('fr'));

      await controller.setLocale(null);

      expect(controller.locale, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('app_language_code'), isFalse);
    });

    test('setLocale ne fait rien si la langue est inchangée', () async {
      final controller = LocaleController(initialLocale: const Locale('fr'));
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.setLocale(const Locale('fr'));

      expect(notifications, 0);
    });
  });

  testWidgets('LocaleScope expose le contrôleur', (tester) async {
    final controller = LocaleController(initialLocale: const Locale('fr'));
    late LocaleController found;

    await tester.pumpWidget(
      LocaleScope(
        controller: controller,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              found = LocaleScope.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(found, same(controller));
  });
}
