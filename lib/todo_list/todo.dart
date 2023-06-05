// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

enum ToDoState {
  ToDo,
  Doing,
  Done,
}

typedef User = Map<String, dynamic>;

class ToDo {
  late int index;
  late ToDoState state;
  late String task;
  late String detail;
  // Timestamp? deadline = Timestamp.now();
  late User users;
  late int score;

  ToDo({
    this.index = 1,
    this.state = ToDoState.ToDo,
    this.task = '새로운 할 일을 추가해주세요',
    this.detail = '',
    // this.deadline,
    this.users = const {},
    this.score = 10,
  });

  ToDo.fromJson(QueryDocumentSnapshot<Object?> json)
      : this(
          index: json['index'] as int,
          state: ToDoState.values[json['state']!],
          task: json.id,
          detail: json['detail'],
          // deadline: json['deadline'] as Timestamp,
          users: json['users']! as User,
          score: json['score'] as int,
        );

  Map<String, Object?> toJson() {
    return {
      'index': index,
      'state': state.index,
      'detail': detail,
      // 'deadline': deadline,
      'users': users,
      'score': score,
    };
  }

  void resetToDo() {
    index = 1;
    // task = '새로운 할 일을 추가해주세요';
    detail = '';
    // this.deadline,
    users = const {};
    score = 10;
  }
}
