import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:capston/todo_list/todo_list.dart';
import 'package:capston/todo_list/todo.dart';

import 'package:capston/palette.dart';

import 'dart:math';

class ToDoPage extends StatefulWidget {
  final roomID;
  const ToDoPage({super.key, required this.roomID});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  TextEditingController addTodoControl = TextEditingController();
  late final CollectionReference toDoRef;

  @override
  void initState() {
    super.initState();
    toDoRef = FirebaseFirestore.instance
        .collection('exchat')
        .doc(widget.roomID)
        .collection('todo');
    // toDoRef.withConverter<ToDo>(fromFirestore: (snapshot, _) => ToDo.fromJson(snapshot.data()!), toFirestore: (toDo, _) => toDo.toJson(),);

    var task = [
      'study',
      'dance',
      'sing',
      'run',
      'drink',
      'coding',
      'lecture',
      'clean',
      'wash',
      'eat'
    ];

    for (int i = 0; i < 10; i++) {
      addTodoControl.text = task[i];
      addTodo(ToDoState.values[Random().nextInt(3)]);
    }
  }

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

  Future<void> addTodo(ToDoState state) async {
    var toDo = ToDo(
        state: state,
        users: {'Oy5sYPc10EXbuAFMvGtzYt2R7V13': '홍길동', 'testid': '홍길순'},
        bDeadline: false);
    await toDoRef.doc(addTodoControl.text).set(toDo.toJson());
  }
}
