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
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.lightGray,
                      offset: Offset(0.0, 5.0), //(x,y)
                      blurRadius: 3.0,
                    ),
                  ],
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 14.0, top: 4.0, bottom: 12.0),
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
                              color: Palette.brightBlue)),
                    ),
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
              preferredSize: const Size.fromHeight(55),
              child: AppBar(
                  toolbarHeight: 100,
                  centerTitle: true,
                  elevation: 1,
                  title: Text(
                    "${widget.chatScreenState.chat.roomName} 할 일 목록",
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Palette.darkGray),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )),
            ),
            body: ToDoList(
              roomID: widget.roomID,
              chatDataState: widget.chatScreenState,
            ));
  }
}
