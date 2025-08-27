import 'package:flutter/material.dart';
import 'package:simple_beautiful_checklist_exercise/data/database_repository.dart';
import 'package:simple_beautiful_checklist_exercise/data/shared_preferences_repository.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final DatabaseRepository repository = SharedPreferencesRepository();
  runApp(App(repository: repository));
}
