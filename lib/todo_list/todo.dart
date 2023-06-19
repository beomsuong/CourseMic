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
  late Timestamp createDate;
  late Timestamp deadline;
  late List<String> userIDs;
  late int score;

  ToDo({
    this.index = 1,
    this.state = ToDoState.ToDo,
    this.task = '새로운 할 일을 추가해주세요',
    this.detail = '',
    required this.createDate,
    required this.deadline,
    required this.userIDs,
    this.score = 10,
  });

  // factory 를 통해 기존 생성자 인스턴스 반환 및 재활용?
  factory ToDo.fromJson(QueryDocumentSnapshot<Object?> json) {
    return ToDo(
      index: json['index'] as int,
      state: ToDoState.values[json['state']!],
      task: json.id,
      detail: json['detail'],
      createDate: json['createDate'] as Timestamp,
      deadline: json['deadline'] as Timestamp,
      userIDs: List<String>.from(json['userIDs']),
      score: json['score'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'state': state.index,
      'detail': detail,
      'createDate': createDate,
      'deadline': deadline,
      'userIDs': userIDs,
      'score': score,
    };
  }

  void resetToDo() {
    index = 1;
    // task = '새로운 할 일을 추가해주세요';
    detail = '';
    createDate = Timestamp.now();
    deadline = Timestamp.now();
    userIDs.clear();
    score = 10;
  }
}
