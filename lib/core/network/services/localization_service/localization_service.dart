import 'package:techcare_assessment_app/core/localization/l10n/app_localizations.dart';

abstract class LocalizationService {
  void setLocalizations(AppLocalizations localizations);
  String translate(String key);
}
