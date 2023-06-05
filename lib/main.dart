import 'package:capston/todo_list/todo_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables(); //추가
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterConfig.get('apiKey');
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  static const testID = 'mH2pTd2HcfRFSAO9dPVU';
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CourseMic',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ToDoPage(roomID: testID),
    );
  }
}
