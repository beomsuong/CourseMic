import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/notification.dart';
import 'package:capston/palette.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_plus_func.dart';
import 'package:capston/chatting/chat/message/log.dart';

class NewMessage extends StatefulWidget {
  final String roomID;
  final ChatScreenState chatScreenState;
  const NewMessage(
      {Key? key, required this.roomID, required this.chatScreenState})
      : super(key: key);

  @override
  NewMessageState createState() => NewMessageState();
}

class NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  bool block = false;
  var _userEnterMessage = '';

  setBlockFalse() {
    setState(() {
      block = false;
    });
  }

  void _sendMessage() async {
    // FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    widget.chatScreenState.chat.recentMessage = _userEnterMessage;
    widget.chatScreenState.chatDocRef
        .update(widget.chatScreenState.chat.toJson());
    addTextMSG(
      roomID: widget.roomID,
      uid: user.uid,
      content: _userEnterMessage,
    );
    FCMLocalNotification.sendMessageNotification(
      roomID: widget.roomID,
      roomName: widget.chatScreenState.chat.roomName,
      userName: (await widget.chatScreenState.userDocRef.get()).get("name"),
      message: _userEnterMessage,
    );
    _controller.clear();
    setState(() {
      _userEnterMessage = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() {
                    block = !block;
                  });
                },
                icon: Icon(block ? Icons.close_rounded : Icons.add_rounded),
                color: Palette.darkGray,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextField(
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
              ? ChatPlusFunc(
                  roomID: widget.roomID,
                  chatScreenState: widget.chatScreenState,
                )
              : const SizedBox(width: 0, height: 0)
        ],
      ),
    );
  }
}
