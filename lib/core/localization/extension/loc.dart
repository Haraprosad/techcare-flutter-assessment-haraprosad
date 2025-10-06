import 'package:flutter/material.dart' show BuildContext;
import 'package:techcare_assessment_app/core/localization/l10n/app_localizations.dart'
    show AppLocalizations;

extension Localization on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
