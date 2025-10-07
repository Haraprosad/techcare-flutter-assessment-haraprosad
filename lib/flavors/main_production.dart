import 'package:techcare_assessment_app/flavors/app_initializer.dart';
import 'package:techcare_assessment_app/flavors/environment.dart';

/// Entry point for the PRODUCTION build
///
/// Run this with: flutter run -t lib/flavors/main_production.dart
/// Uses the .env.production file for configuration
void main() async {
  const environment = Env.PRODUCTION;
  await initializeApp(environment);
}
