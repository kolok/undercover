# Undercover

Application mobile Flutter pour jouer à **Undercover** (3 à 10 joueurs) sur un
seul téléphone, entièrement hors ligne : la banque de mots est embarquée et
aucune connexion réseau n'est utilisée.

Disponible en **français, anglais, allemand, espagnol et italien**. La langue
suit celle du téléphone et peut être changée depuis l'accueil ; le choix est
conservé d'une session à l'autre.

## Déroulé d'une partie

1. **Accueil** → « Démarrer la partie ».
2. **Nombre de joueurs** : effectifs des undercover (1 à 3) et des Mr White
   (0 à 2). Les civils restent toujours strictement majoritaires.
3. **Jeu** : les cartes sont face cachée. Chacun son tour, un joueur choisit une
   carte libre, saisit son nom puis découvre son mot secret (ou apprend qu'il
   est Mr White). Les cartes déjà prises ne sont plus sélectionnables.
4. **Tour de table** : l'ordre de passage reprend l'ordre de sélection des
   cartes, le premier joueur est tiré par l'application et n'est jamais un
   Mr White. Les indices se donnent à l'oral, puis « Finir le tour » ouvre le
   vote : on touche la carte du joueur éliminé, dont le rôle est révélé mais
   jamais le mot.
5. **Mr White éliminé** : il tente de deviner le mot des civils. S'il trouve, le
   mot est révélé et il gagne la partie.
6. **Fin de partie** : camp vainqueur, mots révélés, récapitulatif des rôles et
   bouton « Rejouer » pour relancer avec de nouveaux mots.

## Structure du code

| Chemin | Rôle |
| --- | --- |
| `lib/game/game_controller.dart` | État de la partie et toutes les règles (distribution, ordre de passage, élimination, victoire) |
| `lib/models/` | `Player`, `Role`, `Winner`, `WordPair` |
| `lib/data/word_bank.dart` | Chargement des listes de mots depuis `assets/words/` |
| `assets/words/<langue>.json` | Une banque de 500 paires de mots par langue |
| `lib/l10n/app_<langue>.arb` | Les textes de l'interface, une langue par fichier |
| `lib/l10n/l10n.dart` | Accès aux traductions (`context.l10n`) et libellés des rôles |
| `lib/l10n/locale_controller.dart` | Langue choisie dans l'application, mémorisée |
| `lib/screens/` | Un fichier par écran du parcours |
| `lib/widgets/` | Carte de joueur, logo masque de théâtre, garde-fou de sortie de partie |
| `lib/theme.dart` | Palette et thème sombre |

## Commandes

```bash
flutter pub get
flutter run       # sur un simulateur ou un appareil connecté
flutter test      # règles du jeu, parcours complet, traductions
flutter analyze
flutter gen-l10n  # régénère lib/l10n/generated/ après modification d'un .arb
```

### Hook Git (format avant commit)

Le dépôt fournit un hook shell (sans Python) qui exécute `dart format lib test`
puis met en zone les fichiers modifiés sous `lib/` et `test/`, comme en CI.

Après un clone, activez-le une fois :

```bash
git config core.hooksPath .githooks
```

(require : `dart` dans le `PATH`, fourni avec Flutter.)

## Ajouter ou modifier une langue

Les textes de l'interface et les listes de mots vivent dans deux endroits
séparés :

- **Interface** : `lib/l10n/app_<langue>.arb`. `app_fr.arb` est le fichier de
  référence : toute clé qui y est ajoutée doit l'être dans les autres. Les
  classes Dart sont générées dans `lib/l10n/generated/` (non versionné,
  reconstruit par `flutter pub get`, `flutter test` ou `flutter gen-l10n`).
- **Mots du jeu** : `assets/words/<langue>.json`, un tableau `pairs` de couples
  `["mot des civils", "mot des undercover"]`. Les deux mots d'une paire doivent
  être proches sans être identiques.

Pour une nouvelle langue, ajouter les deux fichiers, puis référencer le code de
langue dans `WordBank.supportedLanguages`, dans `LocaleController.languageNames`
et dans `CFBundleLocalizations` (`ios/Runner/Info.plist`). Une langue sans liste
de mots retombe sur l'anglais.

## Icône de l'application

L'icône est le logo de l'accueil (`TheaterMaskLogo`), dessiné en code. Après
modification du dessin :

```bash
flutter test --update-goldens test/app_icon_test.dart  # régénère assets/icon/
dart run flutter_launcher_icons                        # Android, iOS, web, macOS
```

