import 'package:capston/chatting/chat_screen.dart';
import 'package:flutter/material.dart';

import 'package:capston/todo_list/todo_list.dart';

import 'package:capston/palette.dart';

class ToDoPage extends StatefulWidget {
  final roomID;
  final ChatScreenState chatScreenState;
  bool bMini;
  ToDoPage(
      {super.key,
      required this.roomID,
      required this.chatScreenState,
      this.bMini = false});

  @override
  State<ToDoPage> createState() => ToDoPageState();
}

// 추후 수정
class ToDoPageState extends State<ToDoPage> {
  @override
  Widget build(BuildContext context) {
    return widget.bMini
        ? Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ToDoPage(
                          roomID: widget.roomID,
                          chatScreenState: widget.chatScreenState,
                        ),
                      ),
                    ),
                    child: const Text("+ 할 일 목록 크게 보기",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Palette.pastelPurple)),
                  ),
                ),
              ),
              Expanded(
                child: ToDoList(
                  roomID: widget.roomID,
                  chatDataState: widget.chatScreenState,
                ),
              ),
            ],
          )
        : Scaffold(
            backgroundColor: Palette.lightGray,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: AppBar(
                toolbarHeight: 100,
                centerTitle: true,
                title: Text(
                  widget.chatScreenState.chat.roomName,
                  style: const TextStyle(color: Colors.black, fontSize: 24),
                ),
                backgroundColor: Colors.white,
              ),
            ),
            body: ToDoList(
              roomID: widget.roomID,
              chatDataState: widget.chatScreenState,
            ));
  }
}
