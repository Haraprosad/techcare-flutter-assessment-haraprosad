import 'package:flutter/material.dart';
import 'package:techcare_assessment_app/core/utils/state_messages.dart';

/// Displays an error message from API failures.
///
/// Takes an API failure model, stops any loading spinners, shows an error toast,
/// and renders the error message on screen. Used when API calls fail.
Widget errorWidgetWithAction({required apiCallFailureModel}) {
  stopLoading();

  showErrorMessage(message: apiCallFailureModel.translatedMessage);

  return Center(child: Text(apiCallFailureModel.translatedMessage));
}
