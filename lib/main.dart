import 'package:flutter/material.dart';

import 'l10n/l10n.dart';
import 'l10n/locale_controller.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final locales = LocaleController();
  await locales.restore();
  runApp(UndercoverApp(locales: locales));
}

class UndercoverApp extends StatefulWidget {
  const UndercoverApp({super.key, this.locales});

  /// La langue choisie dans l'application. Par défaut, celle du téléphone.
  final LocaleController? locales;

  @override
  State<UndercoverApp> createState() => _UndercoverAppState();
}

class _UndercoverAppState extends State<UndercoverApp> {
  late final LocaleController _locales = widget.locales ?? LocaleController();

  /// Une langue inconnue du téléphone retombe sur l'anglais plutôt que sur la
  /// première langue de la liste.
  Locale _resolve(List<Locale>? deviceLocales, Iterable<Locale> supported) {
    for (final locale in deviceLocales ?? const <Locale>[]) {
      for (final candidate in supported) {
        if (candidate.languageCode == locale.languageCode) return candidate;
      }
    }
    return const Locale('en');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _locales,
      builder: (context, _) => LocaleScope(
        controller: _locales,
        child: MaterialApp(
          onGenerateTitle: (context) => context.l10n.appName,
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          locale: _locales.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          localeListResolutionCallback: _resolve,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
