// ignore_for_file: avoid_init_to_null

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:capston/widgets/CircularContainer.dart';
import 'package:capston/palette.dart';
import 'package:capston/todo_list/todo.dart';

const TextHeightBehavior textHeightBehavior = TextHeightBehavior(
    applyHeightToFirstAscent: false, applyHeightToLastDescent: true);

// ignore: must_be_immutable
class ToDoNode extends StatefulWidget {
  ToDo toDo;
  void Function()? onTapDelete;

  ToDoNode({super.key, required this.toDo, this.onTapDelete = null});

  @override
  State<ToDoNode> createState() => _ToDoNodeState();
}

class _ToDoNodeState extends State<ToDoNode> {
  @override
  Widget build(BuildContext context) {
    return ToDoContainer(toDo: widget.toDo, onTapDelete: widget.onTapDelete);
  }
}

// ignore: must_be_immutable
class ToDoElement extends StatefulWidget {
  double width;
  bool bAdd;
  bool bDelete;
  String content;
  Color iconColor;
  Color fontColor;
  void Function()? onTapDone;
  void Function()? onTapText;
  void Function()? onTapDelete;

  ToDoElement({
    super.key,
    required this.content,
    this.iconColor = Palette.lightGray,
    this.fontColor = Palette.lightBlack,
    this.bAdd = false,
    this.onTapDone = null,
    this.onTapText = null,
    this.width = 275,
    this.bDelete = true,
    this.onTapDelete = null,
  });

  @override
  State<ToDoElement> createState() => _ToDoElementState();
}

class _ToDoElementState extends State<ToDoElement> {
  TextEditingController controller = TextEditingController();
  FocusNode node = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.text = widget.bAdd ? '' : widget.content;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
            onTap: widget.onTapDone,
            child: Icon(Icons.circle, color: widget.iconColor)),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: SizedBox(
            width: widget.width,
            height: 30,
            child: InkWell(
              onTap: () {
                node.requestFocus();
                controller.selection = TextSelection(
                    baseOffset: 0, extentOffset: controller.value.text.length);
              },
              child: AbsorbPointer(
                child: TextField(
                  focusNode: node,
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.content,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Palette.lightGray,
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                  keyboardType: TextInputType.text,
                ),
              ),
            ),
          ),
        ),
        if (widget.bDelete)
          GestureDetector(
              onTap: widget.onTapDelete,
              child: Icon(Icons.delete, color: widget.iconColor)),
      ],
    );
  }
}

// ignore: must_be_immutable
class ToDoContainer extends StatefulWidget {
  ToDo toDo;
  void Function()? onTapDelete;

  ToDoContainer({super.key, required this.toDo, this.onTapDelete = null});

  @override
  State<ToDoContainer> createState() => _ToDoContainerState();
}

class _ToDoContainerState extends State<ToDoContainer> {
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
            child: ToDoElement(
              content: widget.toDo.task,
              onTapDelete: widget.onTapDelete,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14.0, left: 12, right: 12),
            child: CircularContainer(
                child: Row(
              children: <Widget>[
                for (var userID in widget.toDo.users.keys)
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      '${widget.toDo.users[userID]} ',
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

class AddToDoNode extends StatefulWidget {
  AddToDoNode({super.key});

  @override
  State<AddToDoNode> createState() => _AddToDoNodeState();
}

class _AddToDoNodeState extends State<AddToDoNode> {
  @override
  Widget build(BuildContext context) {
    return AddToDoContainer();
  }
}

// ignore: must_be_immutable
class AddToDoContainer extends StatefulWidget {
  AddToDoContainer({super.key});

  @override
  State<AddToDoContainer> createState() => _AddToDoContainerState();
}

class _AddToDoContainerState extends State<AddToDoContainer> {
  late ToDo? toDo = null;

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
            child: ToDoElement(
              bAdd: true,
              content: '새로운 할 일을 추가해주세요.',
              bDelete: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14.0, left: 12, right: 12),
            child: CircularContainer(),
          ),
        ],
      ),
    );
  }
}
