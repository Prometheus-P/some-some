import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'core/firebase/remote_config_service.dart';

Future<void> main() async {
  // C4: Firebase 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 원격 구성 초기화
  await RemoteConfigService.instance.init();

  runApp(const ThumbSomeApp());
}
