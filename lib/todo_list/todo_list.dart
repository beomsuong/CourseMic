import 'package:capston/chatting/chat_screen.dart';
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

  ToDoList({Key? key, required this.roomID, required this.chatDataState})
      : super(key: key);

  @override
  State createState() => ToDoListState();
}

class ToDoListState extends State<ToDoList> {
  // ignore: prefer_final_fields
  List<DragAndDropList> _contents = List.empty(growable: true);
  late Stream<StateWithToDo> todoStream;
  List<Color> colors = <Color>[
    Palette.brightViolet,
    Palette.pastelPurple,
    Palette.brightBlue
  ];

  @override
  void initState() {
    super.initState();
    todoStream = initToDoNodes();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: todoStream,
        builder: (context, AsyncSnapshot<StateWithToDo> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Palette.pastelPurple));
          }

          StateWithToDo data = snapshot.data as StateWithToDo;

          _contents.clear();
          for (ToDoState state in ToDoState.values) {
            var toDoDocs = data[state.name]?.docs;

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
                          toDoDocs == null ? '0' : (toDoDocs.length).toString(),
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
                          deadline: Timestamp.now(),
                          userIDs: List<String>.empty(growable: true)),
                      chatDataParent: widget.chatDataState,
                      buildParent: this,
                    ),
                  ),
              ],
            ));

            if (toDoDocs == null) break;

            // index 로 정렬
            toDoDocs.sort(
                (a, b) => (a['index'] as int).compareTo(b['index'] as int));

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
            lastItemTargetHeight: 0,
            children: _contents,
            onItemReorder: _onItemReorder,
            onListReorder: _onListReorder,
            listPadding: const EdgeInsets.only(top: 12, left: 24, right: 24),
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
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
          );
        });
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = _contents[oldListIndex].children.removeAt(oldItemIndex);
      _contents[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _contents.removeAt(oldListIndex);
      _contents.insert(newListIndex, movedList);
    });
  }

  Stream<StateWithToDo> initToDoNodes() async* {
    StateWithToDo stateWithTodo = {};

    for (ToDoState state in ToDoState.values) {
      stateWithTodo[state.name] = await widget.chatDataState.toDoColRef
          .where('state', isEqualTo: state.index)
          .get();
    }

    yield stateWithTodo;
  }

  void rebuildToDo() {
    setState(() {
      todoStream = initToDoNodes();
    });
  }
}

typedef StateWithToDo = Map<String, QuerySnapshot<Object?>>;
