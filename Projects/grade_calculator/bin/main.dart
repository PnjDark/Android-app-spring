import 'package:grade_calculator/cli/wizard.dart';

void main() async {
  final wizard = CliWizard();
  await wizard.run();
}
