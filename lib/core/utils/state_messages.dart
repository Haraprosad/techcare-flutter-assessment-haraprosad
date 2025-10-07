import 'package:flutter_easyloading/flutter_easyloading.dart';

/// Quick helpers for showing toast-style messages using EasyLoading.
/// These wrap the EasyLoading API to keep message displays consistent.

/// Shows a success toast with a checkmark
showSuccessMessage({required String message}) {
  return EasyLoading.showSuccess(message);
}

/// Shows an error toast with an X icon
showErrorMessage({required String message}) {
  return EasyLoading.showError(message);
}

/// Shows a loading spinner with custom text - blocks user interaction
showLoading({required String message}) {
  return EasyLoading.show(status: message, maskType: EasyLoadingMaskType.black);
}

/// Quick way to show "Coming Soon" for features not ready yet
showComingSoon() {
  return EasyLoading.showInfo("Coming Soon...");
}

/// Dismisses any currently showing EasyLoading message
stopLoading() {
  return EasyLoading.dismiss();
}
