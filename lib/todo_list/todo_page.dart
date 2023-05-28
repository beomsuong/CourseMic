import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:capston/todo_list/todo_list.dart';
import 'package:capston/todo_list/todo.dart';

import 'package:capston/palette.dart';

class ToDoPage extends StatefulWidget {
  final roomID;
  ToDoPage({super.key, required this.roomID});

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Palette.lightGray,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
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

  Future<void> addTodo() {
    var toDo = ToDo(
        task: addTodoControl.text,
        users: {'Oy5sYPc10EXbuAFMvGtzYt2R7V13': 'ㅋㅋ', 'testid': '고길동'},
        bDeadline: false);
    return toDoRef.doc(toDo.task).set(toDo.toJson());
  }
}
