import 'package:techcare_assessment_app/flavors/app_initializer.dart';
import 'package:techcare_assessment_app/flavors/environment.dart';

void main() async {
  const environment = Env.STAGING;
  await initializeApp(environment);
}
