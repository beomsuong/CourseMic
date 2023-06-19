import 'package:capston/chatting/chat_screen.dart';
import 'package:flutter/material.dart';

import 'package:capston/todo_list/todo_list.dart';

import 'package:capston/palette.dart';

class ToDoPage extends StatefulWidget {
  final roomID;
  final ChatScreenState chatScreenState;
  final bool bMini;
  final ToDoPageState? todoPageState;

  const ToDoPage(
      {super.key,
      required this.roomID,
      required this.chatScreenState,
      this.bMini = false,
      this.todoPageState});

  @override
  State<ToDoPage> createState() => ToDoPageState();
}

// 추후 수정
class ToDoPageState extends State<ToDoPage> {
  bool bMyTodo = false;

  @override
  void initState() {
    super.initState();
  }

  // ToDoPage + ToDoList > ToDoPage
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
                            todoPageState: this,
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
                  bMini: widget.bMini,
                  todoDataParent: widget.todoPageState ?? this,
                ),
              ),
            ],
          )
        : ToDoList(
            roomID: widget.roomID,
            chatDataState: widget.chatScreenState,
            bMini: widget.bMini,
            todoDataParent: widget.todoPageState ?? this,
          );
  }

  toggleMyTodo() {
    setState(() {
      bMyTodo = !bMyTodo;
    });
  }
}
