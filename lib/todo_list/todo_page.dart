import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capston/todo_list/todo_list.dart';
import 'package:flutter/material.dart';
import 'todo.dart';

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

    toDoRef.get().then(
      (snapshot) {
        snapshot.docs.forEach((ss) {
          print(ss['task']);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: addTodoControl,
            decoration:
                InputDecoration(labelText: '할 일', hintText: '할일을 추가하세요.'),
          ),
          ElevatedButton(onPressed: addTodo, child: Text('추가하기')),
          Expanded(child: ListTileExample()),
        ],
      ),
    );
  }

  Future<void> addTodo() {
    var toDo = ToDo(
        task: addTodoControl.text,
        users: {'Oy5sYPc10EXbuAFMvGtzYt2R7V13': 'ㅋㅋ', 'testid': '고길동'},
        bDeadline: false);
    return toDoRef.doc(toDo.task).set(toDo.toJson());
  }
}
