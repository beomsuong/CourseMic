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

  @override
  void initState() {
    super.initState();
    toDoRef = FirebaseFirestore.instance
        .collection('exchat')
        .doc(widget.roomID)
        .collection('todo');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getToDoNodes(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('대기중');
          }
          final toDoDocs = snapshot.data!.docs;
          _contents.clear();
          for (var data in toDoDocs) {
            var todo = ToDo.fromJson(data);
            print('todo_list.dart : ${todo.state.index}');
            _contents.add(DragAndDropList(
              header: Container(
                padding: EdgeInsets.fromLTRB(10, 8, 0, 8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Palette.pastelPurple,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ToDoElement(
                      circleColor: Palette.pastelPurple,
                      content: todo.state.name,
                      fontColor: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: ShortCircularContainer(
                        child: Text(
                          '10',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Palette.darkGray, height: 2.5),
                          textHeightBehavior: textHeightBehavior,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              children: <DragAndDropItem>[
                DragAndDropItem(
                  child: ToDoNode(
                    toDo: todo,
                  ),
                ),
              ],
            ));
          }

          return DragAndDropLists(
            lastItemTargetHeight: 0,
            children: _contents,
            onItemReorder: _onItemReorder,
            onListReorder: _onListReorder,
            listPadding: const EdgeInsets.only(top: 12, left: 24, right: 24),
            listDraggingWidth: 365,
            // contentsWhenEmpty: Row(
            //   children: <Widget>[
            //     const Expanded(
            //       child: Padding(
            //         padding: EdgeInsets.only(left: 40, right: 10),
            //         child: Divider(),
            //       ),
            //     ),
            //     Text(
            //       'Empty List',
            //       style: TextStyle(
            //           color: Theme.of(context).textTheme.bodySmall!.color,
            //           fontStyle: FontStyle.italic),
            //     ),
            //     const Expanded(
            //       child: Padding(
            //         padding: EdgeInsets.only(left: 20, right: 40),
            //         child: Divider(),
            //       ),
            //     ),
            //   ],
            // ),
            listSizeAnimationDurationMilliseconds: 150,
            listGhost: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
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

  Future<QuerySnapshot<Object?>> getToDoNodes() async =>
      await toDoRef.orderBy('state').get();
}
