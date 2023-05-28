// ignore_for_file: constant_identifier_names

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
  Timestamp? deadline;
  ToDoState state;
  int score, index;

  ToDo(
      {required this.task,
      required this.users,
      required this.bDeadline,
      // ignore: avoid_init_to_null
      this.deadline = null,
      this.state = ToDoState.ToDo,
      this.score = 10,
      this.index = 1});

  ToDo.fromJson(QueryDocumentSnapshot<Object?> json)
      : this(
          task: json['task']! as String,
          users: json['users']! as User,
          bDeadline: json['bDeadline']! as bool,
          state: ToDoState.values[json['state']!],
          deadline: json['deadline'] as Timestamp,
          score: json['score'] as int,
          index: json['index'] as int,
        );

  Map<String, Object?> toJson() {
    return {
      'task': task,
      'users': users,
      'bDeadline': bDeadline,
      'deadline': deadline,
      'state': state.index,
      'score': score,
      'index': index,
    };
  }
}
