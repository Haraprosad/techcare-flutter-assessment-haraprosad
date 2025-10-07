import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techcare_assessment_app/core/localization/locale_constants.dart';
import 'package:techcare_assessment_app/core/localization/l10n/app_localizations.dart';

import 'package:techcare_assessment_app/core/storage/app_storage.dart';
import 'package:injectable/injectable.dart';

part 'locale_event.dart';
part 'locale_state.dart';

/// Handles language/locale switching throughout the app.
///
/// Manages which language the app displays and persists the user's
/// language preference so it's remembered between app sessions.
@singleton
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc(this._storage)
    : super(const LocaleState(LocaleConstants.english)) {
    on<ChangeLocaleEvent>(_onChangeLocale);
    on<InitializeLocale>(_onInitializeLocale);
  }

  final AppStorage _storage;

  /// Changes the app's display language and saves the preference
  void _onChangeLocale(
    ChangeLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    try {
      // Skip if user selected the same language we're already using
      if (event.locale == state.locale) {
        return;
      }

      // Make sure the requested language is actually supported
      if (AppLocalizations.supportedLocales.contains(event.locale)) {
        await _storage.preferences.setLanguage(event.locale.languageCode);
        emit(LocaleState(event.locale));
      } else {
        // Requested language isn't supported, fall back to English
        await _storage.preferences.setLanguage(
          LocaleConstants.english.languageCode,
        );
        emit(const LocaleState(LocaleConstants.english));
      }
    } catch (e) {
      // Something went wrong saving the preference, just use English
      await _storage.preferences.setLanguage(
        LocaleConstants.english.languageCode,
      );
      emit(const LocaleState(LocaleConstants.english));
    }
  }

  /// Loads the saved language preference when the app starts
  Future<void> _onInitializeLocale(
    InitializeLocale event,
    Emitter<LocaleState> emit,
  ) async {
    final languageCode = _storage.preferences.getLanguage();
    emit(LocaleState(Locale(languageCode)));
  }
}
