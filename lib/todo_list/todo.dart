// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

enum ToDoState {
  ToDo,
  Doing,
  Done,
}

class ToDo {
  late int index;
  late ToDoState state;
  late String task;
  late String detail;
  late Timestamp deadline;
  late List<String> userIDs;
  late int score;

  ToDo({
    this.index = 1,
    this.state = ToDoState.ToDo,
    this.task = '새로운 할 일을 추가해주세요',
    this.detail = '',
    required this.deadline,
    required this.userIDs,
    this.score = 10,
  });

  ToDo.fromJson(QueryDocumentSnapshot<Object?> json)
      : this(
          index: json['index'] as int,
          state: ToDoState.values[json['state']!],
          task: json.id,
          detail: json['detail'],
          deadline: json['deadline'] as Timestamp,
          userIDs: <String>[
            for (var jsonData in json['userIDs']! as List<dynamic>) jsonData,
          ],
          score: json['score'] as int,
        );

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'state': state.index,
      'detail': detail,
      'deadline': deadline,
      'userIDs': userIDs,
      'score': score,
    };
  }

  void resetToDo() {
    index = 1;
    // task = '새로운 할 일을 추가해주세요';
    detail = '';
    deadline = Timestamp.now();
    userIDs.clear();
    score = 10;
  }
}
