// ignore_for_file: avoid_init_to_null

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:capston/widgets/CircularContainer.dart';
import 'package:capston/palette.dart';
import 'package:capston/todo_list/todo.dart';
import 'package:capston/todo_list/todo_list.dart';

const TextHeightBehavior textHeightBehavior = TextHeightBehavior(
    applyHeightToFirstAscent: false, applyHeightToLastDescent: true);

class ToDoNode extends StatefulWidget {
  final CollectionReference<Object?> toDoRef;

  bool bDelete;
  ToDo toDo;

  // ToDoUpper(task)
  // void Function()? onTapDone;
  // void Function()? onTapText;
  // void Function()? onTapButton;
  // void Function()? onTapDeadline;

  // ToDoLower(user)
  // void Function()? onTapMember;
  // void Function()? onTapScore;

  double width;
  Color iconColor;
  Color fontColor;

  ToDoNode({
    super.key,
    required this.toDoRef,
    this.bDelete = true,
    required this.toDo,
    // ToDoUpper(task)
    // this.onTapDone,
    // this.onTapText,
    // this.onTapButton, // Button that process todo
    // this.onTapDeadline,
    // ToDoLower(user)
    // this.onTapMember,
    // this.onTapScore,
    this.width = 220,
    this.iconColor = Palette.lightGray,
    this.fontColor = Palette.lightBlack,
  });

  @override
  State<ToDoNode> createState() => _ToDoNodeState();
}

class _ToDoNodeState extends State<ToDoNode> {
  late ToDoListState? parent;
  // ToDoUpper(task)
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  // ToDoLower(user)
  List<Widget> users = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    parent = context.findAncestorStateOfType<ToDoListState>();
    controller.text = widget.bDelete ? widget.toDo.task : '';
    users = setUsers();

    if (widget.bDelete) {
      focusNode.addListener(() {
        if (!focusNode.hasFocus) {
          updateToDo();
        }
      });
    }
  }

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
            // ToDoUpper(task) =====================================================
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                        onTap: widget.bDelete ? doneToDo : null,
                        child: Icon(Icons.circle, color: widget.iconColor)),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: SizedBox(
                        width: widget.width,
                        child: InkWell(
                          onTap: () {
                            focusNode.requestFocus();
                            controller.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: controller.value.text.length);
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              focusNode: focusNode,
                              controller: controller,
                              decoration: InputDecoration(
                                // border: InputBorder.none,
                                border: const OutlineInputBorder(),
                                hintText: widget.toDo.task,
                                hintStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Palette.lightGray,
                                ),
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.only(left: 2, bottom: 3),
                              ),
                              style: const TextStyle(fontSize: 14),
                              keyboardType: TextInputType.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => _selectDayAndTime,
                          child:
                              Icon(Icons.date_range, color: widget.iconColor),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: widget.bDelete
                          ? GestureDetector(
                              onTap: deleteToDo,
                              child:
                                  Icon(Icons.delete, color: widget.iconColor))
                          : GestureDetector(
                              onTap: addToDo,
                              child: const Text('Add',
                                  style:
                                      TextStyle(color: Palette.pastelPurple))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ToDoUpper(task) =====================================================
          // ToDoLower(user) =====================================================
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, left: 12, right: 12),
            child: CircularContainer(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: showUser,
                  child: Row(
                    children: users,
                  ),
                ),
                GestureDetector(
                  onTap: showScore,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14.0),
                    child: Text(
                      widget.toDo.score.toString(),
                      style: const TextStyle(
                          fontSize: 10,
                          color: Palette.pastelPurple,
                          height: 2.5),
                      textHeightBehavior: textHeightBehavior,
                    ),
                  ),
                )
              ],
            )),
          ),
          // ToDoLower(user) =====================================================
        ],
      ),
    );
  }

  void doneToDo() {
    widget.toDoRef
        .doc(widget.toDo.task)
        .update({'state': ToDoState.Done.index});
    parent!.rebuildToDo();
  }

  void addToDo() {
    // check fill all
    // 1. text / 2. date(Timestamp) / 3. user
    if (controller.text.isEmpty) {
      showError();
      return;
    }

    widget.toDoRef.doc(controller.text).set(widget.toDo.toJson());

    // clear addToDoNode
    controller.text = '';
    widget.toDo.resetToDo();

    parent!.rebuildToDo();
  }

  void updateToDo() {
    if (controller.text == widget.toDo.task && controller.text.isEmpty) return;

    // create new document
    widget.toDoRef.doc(controller.text).set(widget.toDo.toJson());
    // delete old document
    widget.toDoRef.doc(widget.toDo.task).delete();
    // replace old to new
    widget.toDo.task = controller.text;

    parent!.rebuildToDo();
  }

  void deleteToDo() {
    widget.toDoRef.doc(widget.toDo.task).delete();
    parent!.rebuildToDo();
  }

  // ToDo
  // 1. showDeadline
  // 2.
  void showDeadline() {
    DateTime now = DateTime.now();

    showWidget(
        title: const Text('마감기한을 정해주세요'),
        widget: Column(children: const <Widget>[]),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'))
        ]);
  }

  Future _selectDayAndTime(BuildContext context) async {
    DateTime? selectedDay = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2018),
        lastDate: DateTime(2030),
        builder: (BuildContext context, Widget? child) => child!);

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedDay != null && selectedTime != null) {
      //a little check
    }
  }

  void showUser() {
    // user 선택창 구현
  }

  List<Widget> setUsers() {
    if (widget.toDo.users.isEmpty) {
      return List.empty();
    }

    return <Widget>[
      for (var userID in widget.toDo.users.keys)
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            '${widget.toDo.users[userID]} ',
            style: const TextStyle(
                fontSize: 10, color: Palette.darkGray, height: 2.5),
            textHeightBehavior: textHeightBehavior,
          ),
        ),
    ];
  }

  void showScore() {
    Color color = Palette.pastelPurple;

    showWidget(
        title: const Text('점수를 배점해주세요'),
        widget: Wrap(children: [
          StatefulBuilder(builder: (context, state) {
            return SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTickMarkColor: Palette.darkGray,
                inactiveTrackColor: Palette.lightGray,
                thumbColor: color,
                activeTickMarkColor: color,
                // valueIndicatorColor: color,
              ),
              child: Slider(
                value: widget.toDo.score.toDouble(),
                min: 10,
                max: 100,
                divisions: 9,
                label: widget.toDo.score.toString(),
                onChanged: (double value) {
                  state(() {});
                  setState(() {
                    widget.toDo.score = value.toInt();
                  });
                },
              ),
            );
          }),
        ]),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // ToDoNode 일 경우에만 update
                if (widget.bDelete) {
                  widget.toDoRef
                      .doc(widget.toDo.task)
                      .update({'score': widget.toDo.score});
                }
              },
              child: const Text('확인'))
        ]);
  }

  void showError() {
    showWidget(
      widget: const Text(
        '추가할 정보를 모두 채워주세요',
        textAlign: TextAlign.center,
      ),
    );
  }

  void showWidget(
      {Widget? title, required Widget widget, List<Widget>? actions}) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: title,
              content: widget,
              actions: actions,
            ));
  }
}

class ToDoCategory extends StatefulWidget {
  String content;

  void Function()? onTapColor;
  void Function()? onTapText;

  double width;
  Color iconColor;
  Color fontColor;

  ToDoCategory({
    super.key,
    required this.content,
    this.onTapText = null, // Button that process todo
    this.width = 260,
    this.iconColor = Palette.lightGray,
    this.fontColor = Palette.lightBlack,
  });

  @override
  State<ToDoCategory> createState() => _ToDoCategoryState();
}

class _ToDoCategoryState extends State<ToDoCategory> {
  TextEditingController controller = TextEditingController();
  FocusNode node = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
            onTap: widget.onTapColor,
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
                  enabled: false,
                  focusNode: node,
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.content,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: widget.fontColor,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                  keyboardType: TextInputType.text,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
