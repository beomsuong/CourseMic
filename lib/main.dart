import 'chatting/main_screen.dart' as chat;
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables(); //추가
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterConfig.get('apiKey');
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatting app',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const chat.LoginSignupScreen(),
    );
  }
}
