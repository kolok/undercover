import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/word_pair.dart';

/// Banque de mots hors ligne : une liste par langue, dans
/// `assets/words/<langue>.json`.
///
/// Chaque fichier contient un tableau `pairs` de couples
/// `["mot des civils", "mot des undercover"]`.
class WordBank {
  WordBank({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  /// Une liste chargée reste en mémoire : elle sert à toutes les parties.
  final Map<String, List<WordPair>> _cache = {};

  /// Les langues qui ont leur propre liste de mots.
  static const Set<String> supportedLanguages = {'fr', 'en', 'de', 'es', 'it'};

  /// Liste utilisée quand la langue du téléphone n'en a pas.
  static const String fallbackLanguage = 'en';

  static String _resolve(String languageCode) =>
      supportedLanguages.contains(languageCode) ? languageCode : fallbackLanguage;

  /// Les paires de mots de [languageCode], repliées sur l'anglais si cette
  /// langue n'a pas de liste.
  Future<List<WordPair>> load(String languageCode) async {
    final language = _resolve(languageCode);
    final cached = _cache[language];
    if (cached != null) return cached;

    final raw = await _bundle.loadString('assets/words/$language.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final pairs = [
      for (final pair in data['pairs'] as List)
        WordPair((pair as List)[0] as String, pair[1] as String),
    ];
    return _cache[language] = List.unmodifiable(pairs);
  }
}

/// Banque partagée par toute l'application.
final WordBank wordBank = WordBank();
