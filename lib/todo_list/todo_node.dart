import 'package:flutter/material.dart';

import 'package:capston/widgets/CircularContainer.dart';
import 'package:capston/palette.dart';
import 'package:capston/todo_list/todo.dart';

// ignore: must_be_immutable
class ToDoNode extends StatefulWidget {
  ToDo toDo;

  ToDoNode({super.key, required this.toDo});

  @override
  State<ToDoNode> createState() => _ToDoNodeState();
}

const TextHeightBehavior textHeightBehavior = TextHeightBehavior(
    applyHeightToFirstAscent: false, applyHeightToLastDescent: true);

class _ToDoNodeState extends State<ToDoNode> {
  @override
  Widget build(BuildContext context) {
    return ToDoContainer(toDo: widget.toDo);
  }
}

// ignore: must_be_immutable
class ToDoElement extends StatelessWidget {
  String content;
  Color circleColor;
  Color fontColor;
  void Function()? onTap;

  ToDoElement(
      {super.key,
      required this.content,
      this.circleColor = Palette.lightGray,
      this.fontColor = Palette.lightBlack,
      // ignore: avoid_init_to_null
      this.onTap = null});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
            onTap: onTap, child: Icon(Icons.circle, color: circleColor)),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text(
            content,
            style: TextStyle(fontSize: 14, height: 2.5, color: fontColor),
            textHeightBehavior: textHeightBehavior,
          ),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class ToDoContainer extends StatelessWidget {
  ToDo toDo;

  ToDoContainer({super.key, required this.toDo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ToDoElement(content: toDo.task),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14.0, left: 12, right: 12),
            child: CircularContainer(
                child: Row(
              children: <Widget>[
                for (var userID in toDo.users.keys)
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      '${toDo.users[userID]} | ',
                      style: TextStyle(
                          fontSize: 10, color: Palette.darkGray, height: 2.5),
                      textHeightBehavior: textHeightBehavior,
                    ),
                  ),
              ],
            )),
          ),
        ],
      ),
    );
  }
}
