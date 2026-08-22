# Publication sur Google Play — Undercover

Tout ce qui est nécessaire à la fiche est dans ce dossier. Le bundle à envoyer :
`build/app/outputs/bundle/release/app-release.aab` (versionCode 1, 1.0.0).

## Visuels prêts à téléverser

| Fichier | Usage Play Console |
| --- | --- |
| `icon-512.png` | Icône de l'application (512×512) |
| `feature-graphic.png` | Image de présentation (1024×500) |
| `01-accueil.png` … `06-victoire.png` | Captures d'écran téléphone (1080×1920) |

La politique de confidentialité est publiée par GitHub Pages depuis `docs/` :
<https://kolok.github.io/undercover/>

Régénérer ces visuels après un changement d'UI :

```bash
flutter test --update-goldens test/store_assets_generator.dart
sips -Z 512 assets/icon/app_icon.png --out store/icon-512.png
```

## Textes de la fiche

**Nom de l'application** (30 car. max)

```
Undercover
```

**Description courte** (80 car. max)

```
Le jeu de bluff et de déduction, sur un seul téléphone. 3 à 10 joueurs.
```

**Description longue** (4000 car. max)

```
Undercover est un jeu de bluff et de déduction qui se joue de 3 à 10 joueurs,
avec un seul téléphone qui passe de main en main. Aucune connexion nécessaire :
tout fonctionne hors ligne.

CHACUN SON MOT
Chaque joueur reçoit secrètement un mot. Les civils ont tous le même. Les
undercover en reçoivent un proche, mais différent. Et Mr White, lui, n'a aucun
mot : il devra deviner de quoi parlent les autres et improviser.

LE TOUR DE TABLE
Chacun donne un indice à l'oral pour décrire son mot sans jamais le prononcer.
Assez vague pour ne pas se trahir, assez précis pour prouver sa bonne foi. Puis
tout le monde vote : le joueur éliminé voit son rôle révélé, mais jamais son mot.

LA DERNIÈRE CHANCE DE MR WHITE
Éliminé, Mr White peut encore tout renverser : s'il devine le mot des civils,
il remporte la partie à lui seul.

CE QUE FAIT L'APPLICATION
• Distribue les rôles et les mots au hasard, à l'abri des regards
• Tire une paire de mots parmi des centaines
• Gère l'ordre de passage et désigne le premier joueur
• Suit les éliminations et annonce le camp vainqueur

100 % HORS LIGNE
Pas de compte, pas de publicité, pas de collecte de données. Juste un téléphone
posé sur la table, et vos amis à convaincre.
```

**Nom de la version** (interne, non affiché sur le Store)

```
1.0.0 (1)
```

Play Console le pré-remplit avec le versionCode du bundle. La convention
`versionName (versionCode)` permet de relier une release à un build d'un coup
d'œil ; à la prochaine mise à jour, ce sera `1.0.1 (2)`.

**Notes de version** (500 car. max, affichées dans « Nouveautés »)

```
Première version d'Undercover !

• De 3 à 10 joueurs, avec un seul téléphone
• 1 à 3 undercover et jusqu'à 2 Mr White par partie
• Rôles et mots distribués à l'abri des regards
• Des centaines de paires de mots, 100 % hors ligne

Bon bluff !
```

Si la console affiche le champ multilingue, encadrer le texte :
`<fr-FR>…</fr-FR>`.

## Réponses aux questionnaires « Contenu de l'application »

- **Politique de confidentialité** : <https://kolok.github.io/undercover/>
- **Accès à l'application** : aucun identifiant requis, tout est accessible.
- **Annonces** : l'application ne contient pas d'annonces.
- **Classification du contenu** : catégorie *Jeu — Puzzle / Réflexion*, aucune
  violence, aucun contenu sexuel, aucun langage grossier, aucune substance,
  aucun achat, aucun partage de données ni de localisation → PEGI 3.
- **Public cible** : 13 ans et plus (éviter les tranches < 13 ans, qui imposent
  les règles du programme Familles).
- **Sécurité des données** : aucune donnée collectée, aucune donnée partagée.
  Réponse « Non » à toutes les catégories. Pas de chiffrement en transit à
  déclarer puisque rien ne transite.
- **Application gouvernementale / financière / santé** : non.
- **Contenu généré par les utilisateurs** : non (les prénoms restent locaux et
  ne sont ni stockés ni transmis).

## Étapes dans la Play Console

1. **Créer l'application** : nom `Undercover`, français (France) comme langue par
   défaut, type *Application*, gratuite.
2. **Configurer l'application** : dérouler les tâches ci-dessus (confidentialité,
   accès, annonces, classification, public cible, sécurité des données).
3. **Fiche Play Store principale** : textes et visuels de ce document.
4. **Production → Créer une release** :
   - accepter **Play App Signing** (Google gère la clé de signature finale, la
     clé locale `~/upload-keystore.jks` reste la clé d'upload) ;
   - téléverser `app-release.aab` ;
   - coller les notes de version ;
   - sélectionner les pays de distribution.
5. **Envoyer pour examen**. Comptez généralement quelques jours pour une
   première publication.

## Mises à jour suivantes

Incrémenter la version dans `pubspec.yaml` (`1.0.1+2`, le `+n` étant le
versionCode, obligatoirement croissant), puis :

```bash
flutter build appbundle --release
```
