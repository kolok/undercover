import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'generated/app_localizations.dart';

/// Langue choisie dans l'application, conservée d'une session à l'autre.
///
/// `null` signifie « suivre la langue du téléphone ».
class LocaleController extends ChangeNotifier {
  LocaleController({Locale? initialLocale}) : _locale = initialLocale;

  static const _storageKey = 'app_language_code';

  Locale? _locale;

  Locale? get locale => _locale;

  /// Nom de chaque langue, écrit dans cette langue. L'ordre des clés est
  /// celui du sélecteur.
  static const Map<String, String> languageNames = {
    'fr': 'Français',
    'en': 'English',
    'de': 'Deutsch',
    'es': 'Español',
    'it': 'Italiano',
  };

  /// Les langues proposées dans le sélecteur. Toutes sont traduites : voir
  /// [AppLocalizations.supportedLocales].
  static List<Locale> get selectableLocales => [
        for (final code in languageNames.keys) Locale(code),
      ];

  /// Relit le choix enregistré. Une valeur inconnue est ignorée.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);
    if (code == null || !languageNames.containsKey(code)) return;
    _locale = Locale(code);
    notifyListeners();
  }

  /// [locale] à `null` pour revenir à la langue du téléphone.
  Future<void> setLocale(Locale? locale) async {
    if (_locale?.languageCode == locale?.languageCode) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_storageKey);
    } else {
      await prefs.setString(_storageKey, locale.languageCode);
    }
  }
}

/// Donne accès au choix de langue depuis n'importe quel écran.
class LocaleScope extends InheritedWidget {
  const LocaleScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final LocaleController controller;

  static LocaleController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<LocaleScope>()!
      .controller;

  @override
  bool updateShouldNotify(LocaleScope oldWidget) =>
      controller != oldWidget.controller;
}
