import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/todo_list/todo_calendar.dart';
import 'package:capston/todo_list/todo_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';

import 'package:capston/widgets/CircularContainer.dart';

import 'package:capston/todo_list/todo_node.dart';
import 'package:capston/todo_list/todo.dart';

import 'package:capston/palette.dart';

// ignore: must_be_immutable
class ToDoList extends StatefulWidget {
  String roomID;
  final ChatScreenState chatDataState;
  final bool bMini;
  final ToDoPageState todoDataParent;

  ToDoList({
    Key? key,
    required this.roomID,
    required this.chatDataState,
    this.bMini = false,
    required this.todoDataParent,
  }) : super(key: key);

  @override
  State createState() => ToDoListState();
}

typedef StateWithToDo = Map<String, List<QueryDocumentSnapshot<Object?>>>;

class ToDoListState extends State<ToDoList> {
  // ignore: prefer_final_fields
  final List<DragAndDropList> _contents = List.empty(growable: true);
  late Stream<QuerySnapshot<Object?>> todoStream;

  List<Color> colors = <Color>[
    Palette.brightViolet,
    Palette.pastelPurple,
    Palette.brightBlue
  ];

  @override
  void initState() {
    super.initState();
    todoStream = widget.chatDataState.toDoColRef.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.lightGray,
      appBar: !widget.bMini
          ? PreferredSize(
              preferredSize: const Size.fromHeight(55),
              child: AppBar(
                toolbarHeight: 100,
                centerTitle: true,
                elevation: 1,
                title: Text(
                  "${widget.chatDataState.chat.roomName} 할 일 목록",
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
                backgroundColor: Colors.white,
                automaticallyImplyLeading: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Palette.darkGray),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  IconButton(
                      padding: const EdgeInsets.only(top: 4, right: 6),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ToDoCalendar(
                                    chatDataParent: widget.chatDataState,
                                    todoDataParent: this,
                                  ))),
                      icon: const Icon(Icons.calendar_today_rounded,
                          color: Palette.pastelPurple)),
                ],
              ),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: [
            StreamBuilder(
                stream: todoStream,
                builder:
                    (context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Palette.pastelPurple));
                  }

                  final todoDocs = snapshot.data!.docs;
                  StateWithToDo stateWithTodo =
                      getStateWithToDo(todoDocs, widget.todoDataParent.bMyTodo);

                  _contents.clear();
                  for (ToDoState state in ToDoState.values) {
                    var toDoDocs = stateWithTodo[state.name];

                    _contents.add(DragAndDropList(
                      header: Container(
                        padding: const EdgeInsets.fromLTRB(10, 8, 0, 8),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors[state.index],
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            ToDoCategory(
                              content: state.name,
                              width: 100,
                              iconColor: colors[state.index],
                              fontColor: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: ShortCircularContainer(
                                child: Text(
                                  toDoDocs == null
                                      ? '0'
                                      : (toDoDocs.length).toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Palette.darkGray, height: 2.5),
                                  textHeightBehavior: textHeightBehavior,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      children: <DragAndDropItem>[
                        if (state != ToDoState.Done)
                          DragAndDropItem(
                            canDrag: false,
                            // AddToDo
                            child: ToDoNode(
                              bDelete: false,
                              toDo: ToDo(
                                  state: state,
                                  createDate: Timestamp.now(),
                                  deadline: Timestamp.now(),
                                  userIDs: List<String>.empty(growable: true)),
                              chatDataParent: widget.chatDataState,
                              buildParent: this,
                            ),
                          ),
                      ],
                      contentsWhenEmpty: const SizedBox(
                          height: 60,
                          child: Center(
                              child: Text("아직 완료된 일이 없습니다",
                                  style: TextStyle(color: Palette.darkGray)))),
                    ));

                    if (toDoDocs == null) break;

                    // index 로 정렬
                    toDoDocs.sort((a, b) =>
                        (a['index'] as int).compareTo(b['index'] as int));

                    for (var doc in toDoDocs) {
                      ToDo todo = ToDo.fromJson(doc);
                      _contents[state.index].children.add(DragAndDropItem(
                            canDrag: state != ToDoState.Done,
                            child: ToDoNode(
                              key: ValueKey(doc.id),
                              toDo: todo,
                              chatDataParent: widget.chatDataState,
                              buildParent: this,
                            ),
                          ));
                    }
                  }

                  return DragAndDropLists(
                    lastListTargetSize: 0,
                    lastItemTargetHeight: 15,
                    children: _contents,
                    onItemReorder: _onItemReorder,
                    onListReorder: _onListReorder,
                    listPadding:
                        const EdgeInsets.only(top: 12, left: 24, right: 24),
                    listDraggingWidth: 365,
                    listSizeAnimationDurationMilliseconds: 150,
                    listGhost: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                    ),
                    listDecoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                  );
                }),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 40,
                color: Colors.white.withOpacity(0.7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Opacity(
                      opacity: widget.todoDataParent.bMyTodo ? 0.9 : 0.7,
                      child: ChoiceChip(
                        label: const Text("나의 할 일"),
                        labelStyle: const TextStyle(color: Colors.white),
                        selected: widget.todoDataParent.bMyTodo,
                        selectedColor: Palette.pastelPurple,
                        backgroundColor: Palette.darkGray,
                        onSelected: (_) {
                          setState(() {
                            widget.todoDataParent.toggleMyTodo();
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    ToDoNode movedNode =
        _contents[oldListIndex].children[oldItemIndex].child as ToDoNode;

    if (newListIndex == ToDoState.Done.index) return;

    widget.chatDataState.toDoColRef
        .doc(movedNode.toDo.task)
        .update({"index": newItemIndex, "state": newListIndex});
    if (oldListIndex == newListIndex) {
      ToDoNode originNode =
          _contents[newListIndex].children[newItemIndex].child as ToDoNode;
      widget.chatDataState.toDoColRef
          .doc(originNode.toDo.task)
          .update({"index": oldItemIndex});
    }
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    // setState(() {
    //   var movedList = _contents.removeAt(oldListIndex);
    //   _contents.insert(newListIndex, movedList);
    // });
  }

  // Stream<StateWithToDo> initToDoNodes() async* {
  //   StateWithToDo stateWithTodo = {};

  //   for (ToDoState state in ToDoState.values) {
  //     stateWithTodo[state.name] = await widget.chatDataState.toDoColRef
  //         .where('state', isEqualTo: state.index)
  //         .get();
  //   }

  //   // ...

  //   yield stateWithTodo;
  // }

  // void rebuildToDo() {
  //   widget.miniToDoState == null ? null : widget.miniToDoState!.rebuildToDo();
  //   setState(() {
  //     todoStream = initToDoNodes();
  //   });
  // }

  StateWithToDo getStateWithToDo(List<QueryDocumentSnapshot<Object?>> todoDocs,
      [bool bMyTodo = false]) {
    StateWithToDo temp = {};
    if (!bMyTodo) {
      for (ToDoState state in ToDoState.values) {
        temp[state.name] = todoDocs
            .where((element) => element["state"] == state.index)
            .toList();
      }
    } else {
      for (ToDoState state in ToDoState.values) {
        temp[state.name] = todoDocs
            .where((element) =>
                element["state"] == state.index &&
                element["userIDs"]
                    .contains(widget.chatDataState.currentUser.uid))
            .toList();
      }
    }

    return temp;
  }
}
