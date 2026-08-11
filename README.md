# Undercover

Application mobile Flutter pour jouer à **Undercover** (3 à 10 joueurs) sur un
seul téléphone, entièrement hors ligne : la banque de mots est embarquée et
aucune connexion réseau n'est utilisée.

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
| `lib/data/word_pairs.dart` | Banque de paires de mots hors ligne |
| `lib/screens/` | Un fichier par écran du parcours |
| `lib/widgets/` | Carte de joueur, logo masque de théâtre, garde-fou de sortie de partie |
| `lib/theme.dart` | Palette et thème sombre |

## Commandes

```bash
flutter pub get
flutter run       # sur un simulateur ou un appareil connecté
flutter test      # règles du jeu + parcours complet
flutter analyze
```

## Icône de l'application

L'icône est le logo de l'accueil (`TheaterMaskLogo`), dessiné en code. Après
modification du dessin :

```bash
flutter test --update-goldens test/app_icon_test.dart  # régénère assets/icon/
dart run flutter_launcher_icons                        # Android, iOS, web, macOS
```

