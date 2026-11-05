import 'package:flutter/widgets.dart';

import '../models/player.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

extension L10nContext on BuildContext {
  /// Les textes de l'application, dans la langue courante.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Libellé traduit d'un rôle, affiché lors des révélations.
extension RoleLabel on Role {
  String label(AppLocalizations l10n) => switch (this) {
    Role.civilian => l10n.roleCivilian,
    Role.undercover => l10n.roleUndercover,
    Role.mrWhite => l10n.roleMrWhite,
  };
}

/// Nom affiché d'un joueur, avec un repli sur le numéro de sa carte tant
/// qu'elle n'a pas été choisie.
extension PlayerDisplayName on Player {
  String displayName(AppLocalizations l10n) =>
      name ?? l10n.defaultCardName(cardId + 1);
}
