enum ToDoState {
  todo,
  doing,
  done,
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
      this.state = ToDoState.todo});

  ToDo.fromJson(Map<String, Object?> json)
      : this(
            task: json['task']! as String,
            users: json['users']! as User,
            bDeadline: json['bDeadline']! as bool,
            deadline: json['deadline']! as DateTime,
            state: json['state']! as ToDoState);

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
