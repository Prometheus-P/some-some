import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService().init();
  runApp(const ThumbSomeApp());
}
