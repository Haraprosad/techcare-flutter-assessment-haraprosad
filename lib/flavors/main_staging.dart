import 'package:techcare_assessment_app/flavors/app_initializer.dart';
import 'package:techcare_assessment_app/flavors/environment.dart';

/// Entry point for the STAGING build
///
/// Run this with: flutter run -t lib/flavors/main_staging.dart
/// Uses the .env.staging file for configuration
void main() async {
  const environment = Env.STAGING;
  await initializeApp(environment);
}
