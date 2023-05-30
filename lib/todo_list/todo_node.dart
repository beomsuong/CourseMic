// ignore_for_file: avoid_init_to_null

import 'package:flutter/material.dart';

import 'package:capston/widgets/CircularContainer.dart';
import 'package:capston/palette.dart';
import 'package:capston/todo_list/todo.dart';

const TextHeightBehavior textHeightBehavior = TextHeightBehavior(
    applyHeightToFirstAscent: false, applyHeightToLastDescent: true);

class ToDoNode extends StatefulWidget {
  bool bDelete;
  String? task;
  ToDo? toDo;
  void Function()? onTapButton;

  ToDoNode(
      {super.key,
      this.bDelete = true,
      this.task,
      this.toDo,
      this.onTapButton = null});

  @override
  State<ToDoNode> createState() => _ToDoNodeState();
}

class _ToDoNodeState extends State<ToDoNode> {
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
              bDelete: widget.bDelete,
              content: widget.bDelete ? widget.task! : '새로운 할 일을 추가해주세요.',
              onTapButton: widget.onTapButton,
            ),
          ),
          // User Choose
          Padding(
            padding: const EdgeInsets.only(bottom: 14.0, left: 12, right: 12),
            child: CircularContainer(
                child: Row(
              children: <Widget>[
                if (widget.bDelete)
                  for (var userID in widget.toDo!.users.keys)
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        '${widget.toDo!.users[userID]} ',
                        style: const TextStyle(
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

class ToDoElement extends StatefulWidget {
  bool bDelete; // reverse is AddToDo
  String content;
  void Function()? onTapDone;
  void Function()? onTapText;
  void Function()? onTapButton;
  double width;
  Color iconColor;
  Color fontColor;

  ToDoElement({
    super.key,
    this.bDelete = true,
    required this.content,
    this.onTapDone = null,
    this.onTapText = null,
    this.onTapButton = null, // Button that process todo
    this.width = 260,
    this.iconColor = Palette.lightGray,
    this.fontColor = Palette.lightBlack,
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
    controller.text = widget.bDelete ? widget.content : '';
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
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Palette.lightGray,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                  keyboardType: TextInputType.text,
                ),
              ),
            ),
          ),
        ),
        if (widget.bDelete)
          GestureDetector(
              onTap: widget.onTapButton,
              child: Icon(Icons.delete, color: widget.iconColor)),
      ],
    );
  }
}
