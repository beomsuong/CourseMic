import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat/message.dart';
import 'chat/new_message.dart';

class ChatScreen extends StatefulWidget {
  final String roomID;
  ChatScreen({Key? key, required this.roomID}) : super(key: key);

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
        title: Text('Chat screen'),
        actions: [
          IconButton(
            icon: Icon(
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
