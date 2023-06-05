//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_plus_func.dart';

class NewMessage extends StatefulWidget {
  final String roomname;
  const NewMessage({Key? key, required this.roomname}) : super(key: key);

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
        .collection('exuser')
        .doc(user!.uid)
        .get();
    FirebaseFirestore.instance
        .collection('exchat')
        .doc(widget.roomname)
        .collection('message')
        .add({
      'text': _userEnterMessage,
      'time': Timestamp.now(),
      'userID': user.uid,
      'userName': userData.data()!['userName'],
      'userImage': userData['picked_image'],
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
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
                    // print('+ button pushed!');
                    // Scaffold.of(context).showBottomSheet<void>(
                    //     (BuildContext context) => ChatPlusFunc());
                  },
                  icon: Icon(Icons.add),
                  color: Colors.blue),
              Expanded(
                child: TextField(
                  //메세지 입력 칸
                  maxLines: null,
                  controller: _controller,
                  decoration: InputDecoration(labelText: 'Send a message...'),
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
                icon: Icon(Icons.send),
                color: Colors.blue,
              ),
            ],
          ),
          block
              ? ChatPlusFunc(
                  roomId: widget.roomname,
                )
              : SizedBox(
                  width: 0, height: 0) //TODO: roomID를 처리하지 않거나, roomID를 가져오는 방법
        ],
      ),
    );
  }
}
