// ignore_for_file: avoid_init_to_null

import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:capston/widgets/CircularContainer.dart';
import 'package:capston/palette.dart';
import 'package:capston/todo_list/todo.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

const TextHeightBehavior textHeightBehavior = TextHeightBehavior(
    applyHeightToFirstAscent: false, applyHeightToLastDescent: true);

const TextStyle purpleText = TextStyle(color: Palette.pastelPurple);

class ToDoNode extends StatefulWidget {
  bool bDelete;
  ToDo toDo;
  double width;
  Color iconColor;
  Color fontColor;

  final ChatScreenState chatDataParent;

  ToDoNode({
    super.key,
    this.bDelete = true,
    required this.toDo,
    this.width = 200,
    this.iconColor = Palette.lightGray,
    this.fontColor = Palette.lightBlack,
    required this.chatDataParent,
  });

  @override
  State<ToDoNode> createState() => _ToDoNodeState();
}

class _ToDoNodeState extends State<ToDoNode> {
  // ToDoUpper(task)
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  // ToDoLower(user)
  List<Widget> users = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    controller.text = widget.bDelete ? widget.toDo.task : '';
    if (widget.bDelete) {
      focusNode.addListener(() {
        if (!focusNode.hasFocus) {
          updateToDo();
        }
      });
    }
    users = setUsers();
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
                        onTap: widget.bDelete &&
                                widget.toDo.state != ToDoState.Done
                            ? doneToDo
                            : null,
                        child: Icon(
                            widget.toDo.state == ToDoState.Done
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: widget.iconColor)),
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
                              enabled: widget.toDo.state != ToDoState.Done,
                              focusNode: focusNode,
                              controller: controller,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                // border: const OutlineInputBorder(),
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
                      padding: const EdgeInsets.only(right: 14.0),
                      child: GestureDetector(
                        onTap: widget.toDo.state != ToDoState.Done
                            ? showScore
                            : null,
                        child: Text(
                          "${widget.toDo.score > 0 ? "+" : ""}${widget.toDo.score}",
                          style: const TextStyle(
                            color: Palette.brightBlue,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: widget.bDelete
                          ? GestureDetector(
                              onTap: deleteToDo,
                              child:
                                  Icon(Icons.delete, color: widget.iconColor))
                          : GestureDetector(
                              onTap: addToDo,
                              child: const Text('추가',
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
                  onTap: widget.toDo.state != ToDoState.Done ? showUser : null,
                  child: Row(
                    children: users,
                  ),
                ),
                GestureDetector(
                  onTap:
                      widget.toDo.state != ToDoState.Done ? showDeadline : null,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14.0),
                    child: timestampToText(widget.toDo.deadline),
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
    int bonusScore = 0;
    String userName = widget
        .chatDataParent.userNameList[widget.chatDataParent.currentUser.uid]!;
    String resultUser =
        widget.toDo.userIDs.contains(widget.chatDataParent.currentUser.uid)
            ? "성실한 "
            : "솔선수범한 ";

    late String additionalString;

    bonusScore +=
        widget.toDo.userIDs.contains(widget.chatDataParent.currentUser.uid)
            ? 0
            : 20;
    int diffDay = getDeadlineDiff().inDays;
    bonusScore += diffDay >= 0 ? diffDay * 2 : diffDay * 5;

    diffDay < 0 ? resultUser = "파이팅이 필요한 " : null;
    switch (resultUser) {
      case "성실한 ":
        additionalString = "계속 이렇게만 해주세요!";
        break;
      case "솔선수범한 ":
        additionalString = "휼륭해요! 하지만 혼자만하면 힘드니 다른 조원에게도 같이 해보자고 말해봐요!";
        break;
      case "파이팅이 필요한 ":
        additionalString = "늦었긴했지만 그래도 끝까지 책임지는 모습 칭찬해요! 조금 더 힘내봐요!";
        break;
    }
    resultUser += "$userName!";

    showWidget(
        title: Text("${widget.toDo.task}을(를) 완료하셨나요?"),
        widget: Wrap(children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(resultUser,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const Text("총 참여도 보상은"),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("기존 완료 보상 "),
                Text("${widget.toDo.score} 포인트",
                    style: const TextStyle(
                        color: Palette.brightBlue,
                        fontWeight: FontWeight.bold)),
                const Text("와"),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("추가 완료 보상 "),
                Text("$bonusScore 포인트",
                    style: TextStyle(
                        color: bonusScore >= 0
                            ? Palette.brightBlue
                            : Palette.brightViolet,
                        fontWeight: FontWeight.bold)),
                const Text("로"),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("총 "),
                Text("${widget.toDo.score + bonusScore} 포인트",
                    style: TextStyle(
                        color: (widget.toDo.score + bonusScore >= 0)
                            ? Palette.brightBlue
                            : Palette.brightViolet,
                        fontWeight: FontWeight.bold)),
                const Text("입니다!"),
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(additionalString,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Palette.brightBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ]),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    return;
                  },
                  child: const Text('취소', style: purpleText)),
              TextButton(
                  onPressed: () {
                    List<int> userIndexs = List<int>.empty(growable: true);
                    for (String userID in widget.toDo.userIDs) {
                      int userIndex = widget.chatDataParent.chat
                          .getIndexOfUser(userID: userID);
                      if (userIndex == -1) continue;
                      userIndexs.add(userIndex);
                    }

                    // 불필요하면 삭제
                    widget.toDo.state = ToDoState.Done;
                    widget.toDo.deadline = Timestamp.now();
                    widget.toDo.score += bonusScore;

                    widget.chatDataParent.toDoColRef
                        .doc(widget.toDo.task)
                        .update({
                      'state': widget.toDo.state.index,
                      'deadline': Timestamp.now(),
                      'score': widget.toDo.score,
                    });

                    for (int userIndex in userIndexs) {
                      widget.chatDataParent.chat.userList[userIndex]
                          .participation += widget.toDo.score;
                      widget
                          .chatDataParent.chat.userList[userIndex].doneCount++;
                    }
                    // 혹시 성능에 문제가 있을 경우, 부분적으로 업데이트 되도록 수정 필요
                    widget.chatDataParent.chatDocRef
                        .update(widget.chatDataParent.chat.toJson());

                    Navigator.of(context).pop();
                  },
                  child: const Text('확인', style: purpleText)),
            ],
          )
        ]);
  }

  void addToDo() {
    if (controller.text.isEmpty ||
        widget.toDo.userIDs.isEmpty ||
        getDeadlineDiff().inMinutes < 10) {
      showError();
      return;
    }

    widget.toDo.createDate = Timestamp.now();

    widget.chatDataParent.toDoColRef
        .doc(controller.text)
        .set(widget.toDo.toJson());

    sendToDoNotificationContain(widget.toDo.userIDs);

    // clear addToDoNode
    controller.text = '';
    widget.toDo.resetToDo();
    users = setUsers();
  }

  Future<void> sendToDoNotificationContain(List<String> userIDs) async {
    for (var userID in userIDs) {
      if (widget.chatDataParent.currentUser.uid == userID) continue;
      FCMLocalNotification.sendToDoNotification(
          deviceToken: (await FirebaseFirestore.instance
                  .collection('user')
                  .doc(userID)
                  .get())
              .get('deviceToken'),
          roomID: widget.chatDataParent.widget.roomID,
          roomName: widget.chatDataParent.chat.roomName,
          task: widget.toDo.task);
    }
  }

  void updateToDo() {
    if (controller.text == widget.toDo.task || controller.text.isEmpty) return;

    // create new document
    widget.chatDataParent.toDoColRef
        .doc(controller.text)
        .set(widget.toDo.toJson());
    // delete old document
    widget.chatDataParent.toDoColRef.doc(widget.toDo.task).delete();
    // replace old to new
    widget.toDo.task = controller.text;
  }

  // TODO : Add delete dialog
  void deleteToDo() {
    widget.chatDataParent.toDoColRef.doc(widget.toDo.task).delete();
  }

  void showDeadline() async {
    DateTime now = DateTime.now();

    DateTime? dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: widget.bDelete ? widget.toDo.deadline.toDate() : now,
      firstDate: DateTime(now.year),
      lastDate: DateTime(now.year + 5),
    );

    if (dateTime == null) return;

    setState(() {
      widget.toDo.deadline = Timestamp.fromDate(dateTime);
    });

    if (widget.bDelete) {
      widget.chatDataParent.toDoColRef
          .doc(widget.toDo.task)
          .update({'deadline': widget.toDo.deadline});
    }
  }

  DateFormat dateFormat = DateFormat("(yy/MM/dd HH:mm)");

// D-DAY Text
  Text timestampToText(Timestamp value) {
    if (widget.toDo.state == ToDoState.Done) {
      return Text(
        "완료${dateFormat.format(value.toDate())}",
        style: const TextStyle(
            fontSize: 10, color: Palette.brightBlue, height: 2.5),
        textHeightBehavior: textHeightBehavior,
      );
    }

    DateTime now = DateTime.now();
    Duration diff = value.toDate().difference(now);

    if (!(widget.bDelete) && diff.inMinutes.ceil() == 0) {
      return const Text(
        "마감기한을 지정해주세요",
        style: TextStyle(fontSize: 10, color: Palette.darkGray, height: 2.5),
        textHeightBehavior: textHeightBehavior,
      );
    }

    bool bRemain = diff.inMinutes >= 0;

    late String dDayFront;

    if (diff.inDays.abs() > 0) {
      dDayFront = "${diff.inDays.ceil().abs()}일 ";
    } else {
      if (diff.inHours.abs() > 0) {
        dDayFront = "${diff.inHours.ceil().abs()}시 ";
      } else {
        dDayFront = "${diff.inMinutes.ceil().abs()}분 ";
      }
    }

    return Text(
      dDayFront + (bRemain ? "남음" : "지남") + dateFormat.format(value.toDate()),
      style: TextStyle(
          fontSize: 10,
          color: bRemain ? Palette.brightBlue : Palette.brightViolet,
          height: 2.5),
      textHeightBehavior: textHeightBehavior,
    );
  }

  Duration getDeadlineDiff() {
    DateTime now = DateTime.now();
    return widget.toDo.deadline.toDate().difference(now);
  }

  void showUser() {
    // user 선택창 구현
    widget.chatDataParent.readInitChatData();
    List<String> currentUserIDs = widget.toDo.userIDs;

    showWidget(
        title: const Text("일할 사람을 선택해주세요"),
        widget: Wrap(children: [
          for (var userID in widget.chatDataParent.userNameList.keys)
            StatefulBuilder(builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                  // 추후 아바타 추가
                  // avatar: ,
                  label: Text(widget.chatDataParent.userNameList[userID]!),
                  labelStyle: const TextStyle(color: Colors.white),
                  selected: widget.toDo.userIDs.contains(userID),
                  selectedColor: Palette.pastelPurple,
                  onSelected: (_) {
                    state(() {});
                    setState(() {
                      widget.toDo.userIDs.contains(userID)
                          ? widget.toDo.userIDs.remove(userID)
                          : widget.toDo.userIDs.add(userID);
                      users = setUsers();
                    });
                  },
                ),
              );
            }),
        ]),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      widget.toDo.userIDs = currentUserIDs;
                      users = setUsers();
                    });
                    Navigator.of(context).pop();
                    return;
                  },
                  child: const Text('취소', style: purpleText)),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (widget.bDelete) {
                      widget.chatDataParent.toDoColRef
                          .doc(widget.toDo.task)
                          .update({"userIDs": widget.toDo.userIDs});
                    }
                  },
                  child: const Text('확인', style: purpleText)),
            ],
          )
        ]);
  }

  List<Widget> setUsers() {
    if (widget.toDo.userIDs.isEmpty) {
      return <Widget>[
        const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text(
            "일할 사람을 배정해주세요",
            style:
                TextStyle(fontSize: 10, color: Palette.darkGray, height: 2.5),
            textHeightBehavior: textHeightBehavior,
          ),
        ),
      ];
    }

    return <Widget>[
      for (var userID in widget.toDo.userIDs)
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            widget.chatDataParent.userNameList[userID]!,
            style: const TextStyle(
                fontSize: 10, color: Palette.darkGray, height: 2.5),
            textHeightBehavior: textHeightBehavior,
          ),
        )
    ];
  }

  void showScore() {
    int currentScore = widget.toDo.score;
    Color color = Palette.brightBlue;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      widget.toDo.score = currentScore;
                    });
                    Navigator.of(context).pop();
                    return;
                  },
                  child: const Text('취소',
                      style: TextStyle(color: Palette.brightBlue))),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // ToDoNode 일 경우에만 update
                    if (widget.bDelete) {
                      widget.chatDataParent.toDoColRef
                          .doc(widget.toDo.task)
                          .update({'score': widget.toDo.score});
                    }
                  },
                  child: const Text('확인',
                      style: TextStyle(color: Palette.brightBlue)))
            ],
          ),
        ]);
  }

  void showError() {
    showWidget(
      widget: const Text(
        '등록할 할 일의 정보를 모두 채워주세요',
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
