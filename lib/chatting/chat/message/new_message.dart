//import 'dart:math';

import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/palette.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_plus_func.dart';

class NewMessage extends StatefulWidget {
  final String roomID;
  final ChatScreenState chatScreenState;
  const NewMessage(
      {Key? key, required this.roomID, required this.chatScreenState})
      : super(key: key);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  bool block = false;
  var _userEnterMessage = '';
  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .get();
    FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.roomID)
        .collection('message')
        .add({
      'text': _userEnterMessage,
      'time': Timestamp.now(),
      'userID': user.uid,
      'userName': userData.data()!['name'],
      'userImage': userData['imageURL'],
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // send message container background
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                  //메세지 추가 기능 버튼
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      block = !block;
                    });
                  },
                  icon: Icon(block ? Icons.close_rounded : Icons.add_rounded),
                  color: Palette.darkGray),
              Expanded(
                child: TextField(
                  //메세지 입력 칸
                  maxLines: null,
                  controller: _controller,
                  decoration:
                      const InputDecoration(labelText: 'Send a message...'),
                  onTap: () {
                    setState(() {
                      block = false;
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      _userEnterMessage = value;
                    });
                  },
                ),
              ),
              IconButton(
                onPressed:
                    _userEnterMessage.trim().isEmpty ? null : _sendMessage,
                icon: const Icon(Icons.rocket_launch_rounded),
                color: Palette.darkGray,
              ),
            ],
          ),
          block
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ChatPlusFunc(
                    roomID: widget.roomID,
                    chatScreenState: widget.chatScreenState,
                  ),
                )
              : const SizedBox(width: 0, height: 0)
        ],
      ),
    );
  }
}
