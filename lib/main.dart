import 'package:capston/chatting/main_screen.dart';
import 'package:capston/palette.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:capston/firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "CourseMic",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Disableground Alert
    // RemoteMessage? message =
    //     await FirebaseMessaging.instance.getInitialMessage();
    // if (message != null) {
    //   // 액션 부분 -> 파라미터는 message.data['test_parameter1'] 이런 방식으로...
    //   print("background message alert");
    //   var roomName = (await FirebaseFirestore.instance
    //           .collection('chat')
    //           .doc(message.data['roomID'])
    //           .get())
    //       .get('roomName');

    //   if (chatListContext.mounted) {
    //     await Navigator.push(
    //       chatListContext,
    //       MaterialPageRoute(
    //         builder: (context) {
    //           return ChatScreen(
    //             roomID: message.data['roomID'],
    //             roomName: roomName,
    //           );
    //         },
    //       ),
    //     );
    //   }
    // }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CourseMic',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      locale: const Locale('ko'),
      theme: ThemeData(primarySwatch: Palette.primary),
      home: const LoginSignupScreen(),
    );
  }
}
