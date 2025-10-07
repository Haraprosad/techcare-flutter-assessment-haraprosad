import 'package:techcare_assessment_app/core/localization/l10n/app_localizations.dart';

import 'package:techcare_assessment_app/core/network/constants/error_messages_key.dart';
import 'package:techcare_assessment_app/core/network/services/localization_service/localization_service.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: LocalizationService)
class GlobalLocalizationService implements LocalizationService {
  AppLocalizations? _localizations;

  @override
  void setLocalizations(AppLocalizations localizations) {
    _localizations = localizations;
  }

  @override
  String translate(String messageKey) {
    if (_localizations == null) {
      return messageKey; // fallback if localizations not set
    }
    return _getLocalizedValue(messageKey);
  }

  String _getLocalizedValue(String messageKey) {
    switch (messageKey) {
      case ErrorMessagesKey.noInternet:
        return _localizations!.error_no_internet;
      case ErrorMessagesKey.connectionTimeout:
        return _localizations!.error_connection_timeout;
      case ErrorMessagesKey.serverError:
        return _localizations!.error_server_error;
      case ErrorMessagesKey.unauthorized:
        return _localizations!.error_unauthorized;
      case ErrorMessagesKey.forbidden:
        return _localizations!.error_forbidden;
      case ErrorMessagesKey.notFound:
        return _localizations!.error_not_found;
      case ErrorMessagesKey.badRequest:
        return _localizations!.error_bad_request;
      case ErrorMessagesKey.connectionError:
        return _localizations!.error_connection_error;
      case ErrorMessagesKey.cancel:
        return _localizations!.error_cancel;
      case ErrorMessagesKey.badCertificate:
        return _localizations!.error_bad_certificate;
      case ErrorMessagesKey.preCall:
        return _localizations!.error_pre_call;
      case ErrorMessagesKey.parsing:
        return _localizations!.error_parsing;
      // Backend error codes
      case ErrorMessagesKey.validationError:
        return _localizations!.error_validation;
      case ErrorMessagesKey.amountInvalid:
        return _localizations!.error_amount_invalid;
      case ErrorMessagesKey.duplicateEntry:
        return _localizations!.error_duplicate_entry;
      case ErrorMessagesKey.resourceNotFound:
        return _localizations!.error_resource_not_found;
      case ErrorMessagesKey.insufficientBalance:
        return _localizations!.error_insufficient_balance;
      case ErrorMessagesKey.invalidDateRange:
        return _localizations!.error_invalid_date_range;
      case ErrorMessagesKey.categoryNotFound:
        return _localizations!.error_category_not_found;
      case ErrorMessagesKey.transactionNotFound:
        return _localizations!.error_transaction_not_found;
      default:
        return _localizations!.error_unknown;
    }
  }
}
