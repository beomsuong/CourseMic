import 'package:flutter/material.dart';

import 'package:capston/todo_list/todo_list.dart';

import 'package:capston/palette.dart';

class ToDoPage extends StatefulWidget {
  final roomID;
  const ToDoPage({super.key, required this.roomID});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Palette.lightGray,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppBar(
            toolbarHeight: 100,
            centerTitle: true,
            title: const Text(
              '팀프로젝트',
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
            backgroundColor: Colors.white,
          ),
        ),
        body: ToDoList(
          roomID: widget.roomID,
        ));
  }
}
