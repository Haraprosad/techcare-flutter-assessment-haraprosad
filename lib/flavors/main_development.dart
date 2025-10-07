import 'package:techcare_assessment_app/flavors/app_initializer.dart';
import 'package:techcare_assessment_app/flavors/environment.dart';

/// Entry point for the DEVELOPMENT build
///
/// Run this with: flutter run -t lib/flavors/main_development.dart
/// Uses the .env.development file for configuration
void main() async {
  const environment = Env.DEVELOPMENT;
  await initializeApp(environment);
}
