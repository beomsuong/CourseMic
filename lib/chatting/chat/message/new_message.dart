import 'package:capston/chatting/chat/message/log.dart';
import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/notification.dart';
import 'package:capston/palette.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_plus_func.dart';
import 'package:http/http.dart' as http;

class NewMessage extends StatefulWidget {
  final String roomID;
  final ChatScreenState chatDataParent;
  const NewMessage(
      {Key? key, required this.roomID, required this.chatDataParent})
      : super(key: key);

  @override
  NewMessageState createState() => NewMessageState();
}

class NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  bool block = false;
  var _userEnterMessage = '';
  String fileExtension = "";
  bool bSending = false;

  setBlockFalse() {
    setState(() {
      block = false;
    });
  }

  void _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || bSending) return;
    bSending = true;

    if (await isUrlContentTypeImage(_userEnterMessage)) {
      addImageMSG(
        roomID: widget.roomID,
        uid: user.uid,
        content: "이미지.$fileExtension $_userEnterMessage",
      );
      widget.chatDataParent.updateRecentMessage("사진");
      FCMLocalNotification.sendMessageNotification(
        roomID: widget.roomID,
        roomName: widget.chatDataParent.chat.roomName,
        userName: widget.chatDataParent
            .userNameList[widget.chatDataParent.currentUser.uid]!,
        message: "사진을 보냈습니다",
      );
    } else {
      addTextMSG(
        roomID: widget.roomID,
        uid: user.uid,
        content: _userEnterMessage,
      );
      widget.chatDataParent.updateRecentMessage(_userEnterMessage);
      FCMLocalNotification.sendMessageNotification(
        roomID: widget.roomID,
        roomName: widget.chatDataParent.chat.roomName,
        userName: widget.chatDataParent
            .userNameList[widget.chatDataParent.currentUser.uid]!,
        message: _userEnterMessage,
      );
    }

    _controller.clear();
    setState(() {
      _userEnterMessage = "";
      bSending = false;
    });
  }

  bool isURL(String text) {
    final RegExp urlRegex = RegExp(
      r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
    );

    if (!text.startsWith('http') && !text.startsWith('https')) {
      text = 'https://www.$text';
    }

    return urlRegex.hasMatch(text);
  }

  Future<bool> isUrlContentTypeImage(String url) async {
    http.Response response;
    try {
      response = await http.head(Uri.parse(url));
    } catch (e) {
      return false;
    }

    if (response.statusCode != 200) return false;

    final contentType = response.headers['content-type'];
    if (contentType?.startsWith('image/') ?? false) {
      fileExtension = contentType!.split("/")[1];
      return true;
    }
    return false;
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
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 1000,
                    enabled: !widget.chatDataParent.chat.bEndProject,
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
              IgnorePointer(
                ignoring: widget.chatDataParent.chat.bEndProject,
                child: IconButton(
                  onPressed: _userEnterMessage.trim().isEmpty || bSending
                      ? null
                      : _sendMessage,
                  icon: const Icon(Icons.rocket_launch_rounded),
                  color: Palette.darkGray,
                ),
              ),
            ],
          ),
          block
              ? ChatPlusFunc(
                  roomID: widget.roomID,
                  chatScreenState: widget.chatDataParent,
                )
              : const SizedBox(width: 0, height: 0)
        ],
      ),
    );
  }
}
