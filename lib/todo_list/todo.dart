import 'package:cloud_firestore/cloud_firestore.dart';

enum ToDoState {
  ToDo,
  Doing,
  Done,
}

typedef User = Map<String, dynamic>;

class ToDo {
  final String task;
  User users = {};
  bool bDeadline;
  DateTime? deadline;
  ToDoState state;

  ToDo(
      {required this.task,
      required this.users,
      required this.bDeadline,
      this.deadline = null,
      this.state = ToDoState.ToDo});

  ToDo.fromJson(QueryDocumentSnapshot<Object?> json)
      : this(
          task: json['task']! as String,
          users: json['users']! as User,
          bDeadline: json['bDeadline']! as bool,
          state: ToDoState.values[json['state']!],
        );

  Map<String, Object?> toJson() {
    return {
      'task': task,
      'users': users,
      'bDeadline': bDeadline,
      'deadline': deadline,
      'state': state.index,
    };
  }
}
