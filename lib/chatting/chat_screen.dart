import 'package:capston/palette.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capston/chatting/chat/message/message.dart';
import 'package:capston/chatting/chat/message/new_message.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ChatScreen extends StatefulWidget {
  final String roomID;
  const ChatScreen({Key? key, required this.roomID}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.uid);
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat screen'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.exit_to_app_sharp,
              color: Colors.white,
            ),
            onPressed: () {
              //_authentication.signOut();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            LinearPercentIndicator(
              padding: const EdgeInsets.all(0),
              animation: true,
              animationDuration: 500,
              lineHeight: 8.0,
              percent: 0.9,
              // only one color can accept
              linearGradient: const LinearGradient(colors: [
                Palette.brightViolet,
                Palette.pastelPurple,
                Palette.brightBlue
              ]),
            ),
            Expanded(
              child: Messages(roomID: widget.roomID),
            ),
            NewMessage(roomname: widget.roomID),
          ],
        ),
      ),
    );
  }
}
