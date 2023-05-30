import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

import 'package:capston/widgets/CircularContainer.dart';

import 'package:capston/todo_list/todo_node.dart';
import 'package:capston/todo_list/todo.dart';

import 'package:capston/palette.dart';

// ignore: must_be_immutable
class ToDoList extends StatefulWidget {
  String roomID;
  ToDoList({Key? key, required this.roomID}) : super(key: key);

  @override
  State createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  late final CollectionReference toDoRef;
  // ignore: prefer_final_fields
  List<DragAndDropList> _contents = List.empty(growable: true);
  late Stream<StateWithToDo> todoStream;

  @override
  void initState() {
    super.initState();
    toDoRef = FirebaseFirestore.instance
        .collection('exchat')
        .doc(widget.roomID)
        .collection('todo');

    todoStream = initToDoNodes();
  }

  // Stream<StateWithToDo> updateToDoNodes() async* {
  //   StateWithToDo stateWithTodo = {};

  //   for (ToDoState state in ToDoState.values) {
  //     toDoRef
  //         .where('state', isEqualTo: state.index)
  //         .snapshots(includeMetadataChanges: true)
  //         .listen((event) {
  //       for (var change in event.docChanges) {
  //         if (change.type == DocumentChangeType.removed) {
  //           stateWithTodo[state.name] = event;
  //         }
  //       }
  //     });
  //   }

  //   yield stateWithTodo;
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: todoStream,
        builder: (context, AsyncSnapshot<StateWithToDo> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          StateWithToDo data = snapshot.data as StateWithToDo;

          _contents.clear();
          for (ToDoState state in ToDoState.values) {
            var toDoDocs = data[state.name]?.docs;

            _contents.add(DragAndDropList(
              header: Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 0, 8),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Palette.pastelPurple,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ToDoElement(
                      width: 100,
                      iconColor: Palette.pastelPurple,
                      content: state.name,
                      fontColor: Colors.white,
                      bDelete: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: ShortCircularContainer(
                        child: Text(
                          (toDoDocs?.length).toString(),
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
                DragAndDropItem(
                  canDrag: false,
                  child: ToDoNode(
                    bDelete: false,
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
                    child: ToDoNode(
                      task: doc.id,
                      toDo: todo,
                      onTapButton: () {
                        deleteToDo(doc.id);
                      },
                    ),
                  ));
            }
          }

          return DragAndDropLists(
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
      stateWithTodo[state.name] =
          await toDoRef.where('state', isEqualTo: state.index).get();
    }

    yield stateWithTodo;
  }

  void deleteToDo(String todoID) {
    toDoRef.doc(todoID).delete();
  }
}

typedef StateWithToDo = Map<String, QuerySnapshot<Object?>>;
